{
  lib,
  pkgs,
  config,
  outputs,
  ...
}: let
  # Matrix configs
  domain = "efael.net";
  server = "matrix.${domain}";
  authentication = "auth.${domain}";

  # Coturn configs
  realm = "turn.efael.uz";
  static-auth-secret = "the most niggerlicious thing is to use javascript and python :(";

  # Matrix Client Application
  client = {
    address = "${domain}";
    pkg = pkgs.element-web.override {
      conf = {
        show_labs_settings = true;
        default_theme = "dark";
        brand = "Efael's Network";

        branding = {
          welcome_background_url = "https://cdn2.kolyma.uz/element/bg-floss-uz.png";
          auth_header_logo_url = "https://cdn2.kolyma.uz/element/floss-uz.svg";
        };

        permalink_prefix = "https://${client.address}";
        default_server_config = {
          "m.homeserver" = {
            base_url = "https://${server}";
            server_name = "${domain}";
          };
        };
      };
    };
  };

  temp = "sniggers_and_maniggas";
in {
  imports = [
    outputs.nixosModules.mas
  ];

  config = {
    services.postgresql = {
      enable = lib.mkDefault true;

      # initialScript = pkgs.writeText "synapse-init.sql" ''
      #   CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '${temp}';
      #   CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      #     TEMPLATE template0
      #     LC_COLLATE = "C"
      #     LC_CTYPE = "C";
      # '';
    };

    sops.secrets = {
      "matrix/mail" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "mail/floss/support/raw";
      };
      "matrix/synapse/auth/id" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "matrix/auth/id";
      };
      "matrix/synapse/auth/secret" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "matrix/auth/secret";
      };
      "matrix/mas/auth/id" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "matrix/auth/id";
      };
      "matrix/mas/auth/secret" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "matrix/auth/secret";
      };
    };

    sops.templates."extra-matrix-conf.yaml" = {
      owner = config.systemd.services.matrix-synapse.serviceConfig.User;
      content = ''
        email:
          smtp_host: "mail.floss.uz"
          smtp_port: 587
          smtp_user: "noreply@floss.uz"
          smtp_pass: "${config.sops.placeholder."matrix/mail"}"
          enable_tls: true
          force_tls: false
          require_transport_security: true
          app_name: "Floss Chat"
          enable_notifs: true
          notif_for_new_users: true
          client_base_url: "https://matrix.floss.uz"
          validation_token_lifetime: "15m"
          invite_client_location: "https://chat.floss.uz"
          notif_from: "Floss Chat from <noreply@floss.uz>"
        experimental_features:
          msc3861:
            enabled: true
            issuer: http://localhost:8080/
            client_id: ${config.sops.placeholder."matrix/synapse/auth/id"}
            client_auth_method: client_secret_basic
            client_secret: "${config.sops.placeholder."matrix/synapse/auth/secret"}"
      '';
    };

    sops.templates."extra-mas-conf.yaml" = {
      owner = config.systemd.services.matrix-authentication-service.serviceConfig.User;
      content = ''
        email:
          from: '"Efael" <noreply@floss.uz>'
          reply_to: '"No reply" <noreply@floss.uz>'
          transport: smtp
          mode: tls # plain | tls | starttls
          hostname: mail.floss.uz
          port: 587
          username: noreply@floss.uz
          password: "${config.sops.placeholder."matrix/mail"}"
        matrix:
          kind: synapse
          homeserver: ${domain}
          secret: "${config.sops.placeholder."matrix/mas/auth/secret"}"
          endpoint: "http://localhost:8008"
      '';
    };

    services.matrix-synapse = {
      enable = true;

      extraConfigFiles = [
        config.sops.templates."extra-matrix-conf.yaml".path
      ];

      extras = lib.mkForce [
        "oidc"
        "systemd"
        "postgres"
        "url-preview"
        "user-search"
      ];

      log = {
        loggers."synapse.util.mail".level = "DEBUG";
        loggers."synapse.handlers.email".level = "DEBUG";
        root.level = "INFO";
      };

      settings = {
        server_name = domain;
        public_baseurl = "https://${server}";

        turn_uris = ["turn:${realm}:3478?transport=udp" "turn:${realm}:3478?transport=tcp"];
        turn_shared_secret = static-auth-secret;
        turn_user_lifetime = "1h";

        allow_guest_access = true;
        enable_registration = true;
        registrations_require_3pid = ["email"];
        enable_3pid_changes = true;
        enable_set_displayname = true;
        enable_set_avatar_url = true;

        admin_contact = "mailto:support@floss.uz";

        database.args = {
          password = "${temp}";
        };

        listeners = [
          {
            port = 8008;
            bind_addresses = ["127.0.0.1" "::1"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = ["client" "federation"];
                compress = true;
              }
            ];
          }
        ];
      };
    };

    services.matrix-authentication-service = {
      enable = true;
      createDatabase = true;
      extraConfigFiles = [
        config.sops.templates."extra-mas-conf.yaml".path
      ];

      settings = {
        upstream_oauth2.providers = {};
      };
    };

    services.coturn = rec {
      inherit realm static-auth-secret;
      enable = true;
      no-cli = true;
      no-tcp-relay = true;
      min-port = 49000;
      max-port = 50000;
      use-auth-secret = true;
      cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
      pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
      extraConfig = ''
        # for debugging
        verbose
        # ban private IP ranges
        no-multicast-peers
        external-ip=65.109.74.214
        external-ip=2a01:4f9:3071:31ce::
        denied-peer-ip=0.0.0.0-0.255.255.255
        denied-peer-ip=10.0.0.0-10.255.255.255
        denied-peer-ip=100.64.0.0-100.127.255.255
        denied-peer-ip=127.0.0.0-127.255.255.255
        denied-peer-ip=169.254.0.0-169.254.255.255
        denied-peer-ip=172.16.0.0-172.31.255.255
        denied-peer-ip=192.0.0.0-192.0.0.255
        denied-peer-ip=192.0.2.0-192.0.2.255
        denied-peer-ip=192.88.99.0-192.88.99.255
        denied-peer-ip=192.168.0.0-192.168.255.255
        denied-peer-ip=198.18.0.0-198.19.255.255
        denied-peer-ip=198.51.100.0-198.51.100.255
        denied-peer-ip=203.0.113.0-203.0.113.255
        denied-peer-ip=240.0.0.0-255.255.255.255
        denied-peer-ip=::1
        denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
        denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
        denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
        denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      '';
    };

    networking.firewall = {
      interfaces.eth0 = let
        range = with config.services.coturn; [
          {
            from = min-port;
            to = max-port;
          }
        ];
      in {
        allowedUDPPortRanges = range;
        allowedUDPPorts = [3478 5349];
        allowedTCPPortRanges = [];
        allowedTCPPorts = [3478 5349];
      };
    };

    users.users.nginx.extraGroups = [config.users.groups.turnserver.name];

    security.acme.certs.${config.services.coturn.realm} = {
      postRun = "systemctl restart coturn.service";
      group = lib.mkForce "turnserver";
    };

    services.www.hosts = {
      ${realm} = {
        addSSL = true;
        enableACME = true;
      };

      ${server} = {
        addSSL = true;
        enableACME = true;

        locations."/".extraConfig = ''
          return 404;
        '';

        locations."~ ^(/_matrix|/_synapse/client)" = {
          proxyPass = "http://localhost:8008";
        };

        locations."~ ^/_matrix/client/(.*)/(login|logout|refresh)" = {
          proxyPass = "http://localhost:8080";
        };
      };

      ${authentication} = {
        addSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://localhost:8080";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };

      "${client.address}" = {
        addSSL = true;
        enableACME = true;
        root = client.pkg;
      };
    };
  };
}
