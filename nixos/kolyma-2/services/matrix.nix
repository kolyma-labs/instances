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
        default_server_config = {
          "m.homeserver".base_url = "https://${domain}";
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

    services.matrix-synapse = {
      enable = true;

      settings = {
        server_name = domain;
        public_baseurl = "https://${server}";

        database.args = {
          password = "${temp}";
        };

        registration_shared_secret = "5UmnPFtBwLqu94eJ2PVUV0cOJNEGfZTtVaoPxpX7PWOevx6PrSfaYKzrCAQJzJ2H";

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
