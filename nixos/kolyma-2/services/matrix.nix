{
  lib,
  pkgs,
  config,
  ...
}: let
  domain = "floss.uz";
  server = "chat.${domain}";
in {
  config = {
    services.postgresql.enable = true;

    services.matrix-synapse = {
      enable = true;
      settings.server_name = server;
      settings.public_baseurl = domain;
      settings.listeners = [
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
          reverse_proxy /_matrix/* http://127.0.0.1:8008
        '';
      };
    };

    networking.firewall = {
      allowedTCPPorts = [8008];
      allowedUDPPorts = [8008];
    };
  };
}
