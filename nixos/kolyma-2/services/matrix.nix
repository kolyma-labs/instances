{
  lib,
  pkgs,
  config,
  ...
}: let
  domain = "floss.uz";
  server = "chat.${domain}";

  front = pkgs.element-web.override {
    conf = {
      default_server_config = {
        "m.homeserver".base_url = "https://${domain}";
      };
    };
  };
in {
  config = {
    services.postgresql = {
      enable = lib.mkDefault true;

      ensureDatabases = [
        "matrix-synapse"
      ];

      ensureUsers = [
        {
          name = "matrix-synapse";
          ensureDBOwnership = true;
        }
      ];
    };

    services.matrix-synapse = {
      enable = true;

      settings = {
        server_name = server;
        public_baseurl = "https://${domain}";
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
              "m.server": "${server}"
            }`
          }

          handle {
            redir https://www.{host}{uri} permanent
          }
        '';
      };

      "${server}" = {
        extraConfig = ''
          handle_path /_matrix/* {
            reverse_proxy http://127.0.0.1:8008
          }

          handle_path /_synapse/client {
            reverse_proxy http://127.0.0.1:8008
          }

          root * ${front}
          file_server
        '';
      };
    };

    networking.firewall = {
      allowedTCPPorts = [8008];
      allowedUDPPorts = [8008];
    };
  };
}
