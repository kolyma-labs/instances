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
  realm = "turn.efael.net";
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

        experimental_features:
          msc3861:
            enabled: true
            issuer: https://auth.efael.net/
            client_id: 0000000000000000000SYNAPSE
            client_auth_method: client_secret_basic
            client_secret: "${config.sops.placeholder."matrix/synapse/auth/secret"}"
          msc4108_enabled: true
          msc2965_enabled: true
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
          endpoint: "https://matrix.efael.net"
        secrets:
          encryption: e724403e1380d06bfcec459d0fbd6469cd5c202dcb4b13f1756edf927990d07c
          keys:
          - kid: DQhwdhHMxc
            key: |
              -----BEGIN RSA PRIVATE KEY-----
              MIIEpAIBAAKCAQEAtKFyOEbfIgVITbZTkhkWXsauO0fbxPVh4szHNHAJcmzu/r2a
              nL7A2DURpErWgPML7Zr6tKUxJFRlb9eZJuU69yWYVlH1kWu7ymdhE5u7Sd+3hocB
              HfuZfVMxsZgMDLGTwx505Jr1/bVwoUfx5lS/LuNsVDO3Wd1yc9Ly02WGY8g2qBTs
              4fcahsSECyMYOg/teYAguyi8nFqYl0DlzW3RyuP+lOMglb8O6SFlo5MeamjPnHCt
              T5iQF90gn+irQTLBoGJmyFVXUZi30C11ZCSODrPiq9+8nuT5aliPRDQzSrTGrT4Z
              pr+MzEGWrjrAj7NeQiXNeOCF4ISOpWYY5IWbrQIDAQABAoIBAQCbOiLuOfmHQwLf
              xdALvYN770HLr/UtTbLRNSn75kw4CWVZhZdZHJSdOP3wMmAkcLnPd1/73fpdPint
              81mqE1SZD7XaeJSQZAT969mBAFPzKE6PTXWoTo+ZI+WQuRmhzvkstP+/dWvwm/wu
              naVES5AAu3Bc7BSlJak14BLNmHHlTLfKe2qp5KsrRnrN/uEl7sSRLNoDWN8bACzh
              HZY2pTMdEfhYlf1zIh/rXFICYv/zQLBernw9l1LPjJo4I7XoQqshFXkJNljxdMNt
              nYP6KNGseEvXeuBXH6Pv60wzCYPQyAMn4vzhD8Qlhjr4d4Dpab4d8in7UJtQMHbW
              IjWYdoABAoGBAM7JsI7m1O/1h/6ooHs6nfDS0VNDHtESrUWXs1cxYhh1ASezwsrp
              iHVkCu7UbmKceFMop3jgN0DeJ5/FKwL+3dbno0U76soAAxueDd797ahRfd84MG5A
              qLMk1YFxz69aM9HLmCw89bvit0zmZlXixbfmHkUW2f7dR1BOT5Kn8YDJAoGBAN+e
              KMezyoHEgGuxFZlW78HjQhji3KwsvB/wFlLhmAsSFMdEjVNN0LHlGtb14mVNpUUJ
              dsFTXSmFflTn11bACcYyDY7KdJQenO7y2KvRpa4UJcHs9p20WDlmmzeTKqqCxvmb
              8o9uYqpFIR9QU91vWkUpMRjCDNMU7mAOPzLFGvnFAoGBAJePmAqFARkHGq/5o/Xt
              1okF20ptbY7LY5gYQefsV/uY9knFJUZXuB5iPukhZe58xGwe5fBgVd8DdINTndzK
              NIooqLA75DA9pgl95KjF8IRnhhwvML/+QCddHeeMJS5erJBd6qCx5WHaH4MLc4IL
              feL1lMYKo6h7QqOHYicZVJaRAoGAd1nwBB6m8DoUHOaIU65+CysjpSq4g0DhK961
              24jC4O3Gn1CsaZD32WshtyfHrTATDNTvSGIZMEcq1WBko82dqeYfLF5MeJ4aPsLo
              +FPOLSpduLKkMioGiKSGJdRrilSApMsiXIGbMavx8Mer6106ff1tUfyIYcUjMauI
              +a0QJ80CgYAD0EtY23Zvl71sF7oy2DzCT7xyLm7aHtEXBQTFz9Mz4FQFI3GNXYj8
              RFfKiu7DOJHKhXvr0akIBenquuN2BE0oDpvwf7s5OchGIYTMZKIyRCLDiiUyR37k
              rMNZbArXsj22BueFWYrm8JkKP7auVHNJKazthFrv53KPesawes9VYw==
              -----END RSA PRIVATE KEY-----
          - kid: fK7g4m3Ozg
            key: |
              -----BEGIN EC PRIVATE KEY-----
              MHcCAQEEIAkGSEhYIHsXJrzfm5f5kujfqYWiVc1vdduOmlh5URI9oAoGCCqGSM49
              AwEHoUQDQgAEGsj6JBqiYxP9wMx8fGvKqQWT+aT1td5egbl1SezIfg1dxZEgYUVH
              6yjXaQN0cQ9s509YkMZEstdXgFWutMzw3Q==
              -----END EC PRIVATE KEY-----
          - kid: cePSmzchGk
            key: |
              -----BEGIN EC PRIVATE KEY-----
              MIGkAgEBBDAiTVReSaBjuWWFo3NwLwPp1oc6S38dL151fZDcvktJNpEJPWbhvtEW
              tFpX4k8KdaagBwYFK4EEACKhZANiAAQQOTVsSQgQYavRrSGIOkGYSxIJH3I3vQTp
              IHvlzwyWyRj2+x39vuCvCvypIOJHKmeVI29iiIwnSqA4+qndn2NNd2Y5zNi3CFOW
              fcznXiXkzR4SRP6fhdKmndYhQPLaW5U=
              -----END EC PRIVATE KEY-----
          - kid: SxnO3hEMCg
            key: |
              -----BEGIN EC PRIVATE KEY-----
              MHQCAQEEIDLndBZGc5beWiVVeDClnWIS8PG1bkkBWpqmN8OaRFRFoAcGBSuBBAAK
              oUQDQgAECcZeokwZgclVvUUz8gSkMOIUwWnN2y9WkynOYWSMH4wjl4j2SSLshksP
              PjB1Ne1+ICWa7dia0dDG8OhdCX9UQA==
              -----END EC PRIVATE KEY-----

      '';
    };

    services.matrix-synapse = {
      enable = true;

      extraConfigFiles = [
        config.sops.templates."extra-matrix-conf.yaml".path
      ];

      extras = lib.mkForce [
        "cache-memory" # Provide statistics about caching memory consumption
        "jwt" # JSON Web Token authentication
        "oidc" # OpenID Connect authentication
        "postgres" # PostgreSQL database backend
        "redis" # Redis support for the replication stream between worker processes
        "saml2" # SAML2 authentication
        "sentry" # Error tracking and performance metrics
        "systemd" # Provide the JournalHandler used in the default log_config
        "url-preview" # Support for oEmbed URL previews
        "user-search" # Support internationalized domain names in user-search
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

        suppress_key_server_warning = true;
        allow_guest_access = true;
        # enable_registration = true;
        registration_shared_secret_path = config.sops.secrets."matrix/synapse/auth/secret".path;
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
        http = {
          public_base = "https://auth.efael.net";
          issuer = "https://auth.efael.net";
        };

        account = {
          email_change_allowed = true;
          displayname_change_allowed = true;
          password_registration_enabled = true;
          password_change_allowed = true;
          password_recovery_enabled = true;
        };

        passwords = {
          enabled = true;
          minimum_complexity = 3;
          schemes = [
            {
              version = 1;
              algorithm = "argon2id";
            }
            {
              version = 2;
              algorithm = "bcrypt";
            }
          ];
        };
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

        locations."= /.well-known/matrix/client" = {
          extraConfig = let
            data = {
              "m.server".base_url = "https://${server}";
              "m.homeserver".base_url = "https://${server}";
              "org.matrix.msc2965.authentication" = {
                "issuer" = "https://auth.efael.net/";
                "account" = "https://auth.efael.net";
                "registration" = true;
              };
            };
          in ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON data}';
          '';
        };

        locations."= /.well-known/matrix/server" = {
          extraConfig = ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '{"m.server": "${server}:443"}';
          '';
        };

        locations."/.well-known/openid-configuration" = {
          proxyPass = "http://localhost:8080/.well-known/openid-configuration";
        };

        locations."/" = {
          root = client.pkg;
        };
      };
    };
  };
}
