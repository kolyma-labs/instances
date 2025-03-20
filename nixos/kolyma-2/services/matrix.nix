{
  lib,
  pkgs,
  config,
  ...
}: let
  usergroup = "matrix-synapse";

  domain = "floss.uz";
  server = "matrix.${domain}";
  client = {
    address = "chat.${domain}";
    pkg = pkgs.element-web.override {
      conf = {
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
    };

    sops.templates."extra-matrix-conf.yaml" = {
      owner = config.systemd.services.matrix-synapse.serviceConfig.User;
      content = ''
        email:
          smtp_pass: "${config.sops.placeholder."matrix/mail"}"
          notif_from: Your buddy from %(app) <support@floss.uz>
      '';
    };

    services.matrix-synapse = {
      enable = true;

      extraConfigFiles = [
        config.sops.templates."extra-matrix-conf.yaml".path
      ];

      settings = {
        server_name = domain;
        public_baseurl = "https://${server}";

        allow_guest_access = true;
        enable_registration = true;
        default_identity_server = ["https://matrix.org"];
        suppress_key_server_warning = true;
        registrations_require_3pid = ["email"];

        enable_3pid_changes = true;
        enable_set_displayname = true;
        enable_set_avatar_url = true;

        admin_contact = "mailto:support@floss.uz";

        email = {
          smtp_host = "smtp.mail.me.com";
          smtp_port = 587;
          smtp_user = "sakhib.orzklv@icloud.com";
          force_tls = true;
          require_transport_security = true;
          enable_tls = true;
          notif_from = "Your buddy from %(app) <support@floss.uz>";
          app_name = "Floss Chat";
          enable_notifs = true;
          notif_for_new_users = false;
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
