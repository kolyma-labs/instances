{
  lib,
  pkgs,
  config,
  ...
}: let
  # Matrix configs
  domain = "floss.uz";
  server = "matrix.${domain}";

  # Coturn configs
  realm = "turn.floss.uz";
  static-auth-secret = "the most niggerlicious thing is to use javascript and python :(";

  # Matrix Client Application
  client = {
    address = "chat.${domain}";
    pkg = pkgs.element-web.override {
      conf = {
        show_labs_settings = true;
        default_theme = "dark";
        brand = "Floss Chat";

        branding = {
          welcome_background_url = "https://cdn2.kolyma.uz/element/bg-floss-uz.png";
          auth_header_logo_url = "https://cdn2.kolyma.uz/element/floss-uz.svg";
          auth_footer_links = [
            {
              text = "Mastodon";
              url = "https://social.floss.uz";
            }
            {
              text = "GitHub";
              url = "https://github.com/floss-uz";
            }
          ];
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
      "matrix/oath/github/id" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "oath/github/id";
      };
      "matrix/oath/github/secret" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "oath/github/secret";
      };
      "matrix/oath/mastodon/id" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "oath/mastodon/id";
      };
      "matrix/oath/mastodon/secret" = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        key = "oath/mastodon/secret";
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
        oidc_providers:
          - idp_id: github
            idp_name: Github
            idp_brand: "github"
            discover: false
            issuer: "https://github.com/"
            client_id: "${config.sops.placeholder."matrix/oath/github/id"}"
            client_secret: "${config.sops.placeholder."matrix/oath/github/secret"}"
            authorization_endpoint: "https://github.com/login/oauth/authorize"
            token_endpoint: "https://github.com/login/oauth/access_token"
            userinfo_endpoint: "https://api.github.com/user"
            scopes: ["read:user"]
            user_mapping_provider:
              config:
                subject_claim: "id"
                localpart_template: "{{ user.login }}"
                display_name_template: "{{ user.name }}"
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

        auto_join_rooms = [
          # Spaces
          "#community:floss.uz"
          "#xinux:floss.uz"
          "#rust:floss.uz"

          # Rooms
          "#chat:floss.uz"
          "#help:floss.uz"
          "#mod:floss.uz"
          "#infra:floss.uz"
          "#awesome:floss.uz"
          "#stds:floss.uz"
        ];

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

        locations."/_matrix/" = {
          proxyPass = "http://localhost:8008";
        };

        locations."/_synapse/client/" = {
          proxyPass = "http://localhost:8008";
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
