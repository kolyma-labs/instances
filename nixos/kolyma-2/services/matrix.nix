{
  lib,
  pkgs,
  config,
  ...
}: let
  domain = "floss.uz";
  server = "matrix.${domain}";
  client = {
    address = "chat.${domain}";
    pkg = pkgs.element-web.override {
      conf = {
        show_labs_settings = true;
        default_theme = "dark";
        default_server_config = {
          "m.homeserver".base_url = "https://${server}";
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
        key = "mail/password";
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
          smtp_pass: "${config.sops.placeholder."matrix/mail"}"
          notif_from: "Floss Chat from <support@floss.uz>"
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

          - idp_id: mastodon
            idp_name: "Floss Mastodon"
            discover: false
            issuer: "https://social.floss.uz/@orzklv"
            client_id: "${config.sops.placeholder."matrix/oath/mastodon/id"}"
            client_secret: "${config.sops.placeholder."matrix/oath/mastodon/secret"}"
            authorization_endpoint: "https://social.floss.uz/oauth/authorize"
            token_endpoint: "https://social.floss.uz/oauth/token"
            userinfo_endpoint: "https://social.floss.uz/api/v1/accounts/verify_credentials"
            scopes: ["read"]
            user_mapping_provider:
              config:
                subject_template: "{{ user.id }}"
                localpart_template: "{{ user.username }}"
                display_name_template: "{{ user.display_name }}"
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

      settings = {
        server_name = domain;
        public_baseurl = "https://${server}";

        allow_guest_access = true;
        enable_registration = true;
        registrations_require_3pid = ["email"];

        enable_3pid_changes = true;
        enable_set_displayname = true;
        enable_set_avatar_url = true;

        admin_contact = "mailto:support@floss.uz";

        auto_join_rooms = [
          "#community:floss.uz"
          "#chat:floss.uz"
          "#help:floss.uz"
        ];

        email = {
          smtp_host = "smtp.mail.me.com";
          smtp_port = 587;
          smtp_user = "sakhib.orzklv@icloud.com";
          force_tls = false;
          enable_tls = true;
          require_transport_security = true;
          app_name = "Floss Chat";
          enable_notifs = true;
          notif_for_new_users = true;
          client_base_url = "https://matrix.floss.uz";
          validation_token_lifetime = "15m";
          invite_client_location = "https://chat.floss.uz";
        };

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

    services.www.hosts = {
      "${domain}" = {
        extraConfig = ''
          handle_path /.well-known/matrix/client {
            header Content-Type application/json
            header Access-Control-Allow-Origin "*"

            respond `{
              "m.homeserver": {
                "base_url": "https://${server}"
              }
            }`
          }

          handle_path /.well-known/matrix/server {
            header Content-Type application/json
            header Access-Control-Allow-Origin "*"

            respond `{
              "m.server": "${server}:443"
            }`
          }

          # handle {
          #   redir https://www.{host}{uri} permanent
          # }
        '';
      };

      "${server}" = {
        extraConfig = ''
          reverse_proxy /_matrix/* localhost:8008
          reverse_proxy /_synapse/client/* localhost:8008
        '';
      };

      "${client.address}" = {
        extraConfig = ''
          root * ${client.pkg}
          file_server
        '';
      };
    };
  };
}
