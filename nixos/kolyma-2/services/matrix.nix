{
  config,
  inputs,
  pkgs,
  ...
}: let
  domain_name = "floss.uz";
  secure_token = "niggerlicious";
in {
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      address = "127.0.0.1";
      allow_registration = true;
      registration_token = "${secure_token}";
      database_backend = "rocksdb";
      port = 6167;
      server_name = "${domain_name}";
    };
  };

  services.www.hosts = {
    "${domain_name}" = {
      extraConfig = ''
        handle_path /.well-known/matrix/client {
          header Content-Type application/json
          header Access-Control-Allow-Origin "*"

          respond `{
            "m.homeserver": {
              "base_url": "https://${domain_name}"
            }
          }`
        }

        handle_path /.well-known/matrix/server {
          header Content-Type application/json

          respond `{
            "m.server": "${domain_name}"
          }`
        }

        handle_path /_matrix/* {
          reverse_proxy ${config.services.matrix-conduit.settings.global.address}:${toString config.services.matrix-conduit.settings.global.port}
        }

        handle {
          redir https://www.{host}{uri} permanent
        }
      '';
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [8448];
      allowedUDPPorts = [53 8448];
    };
  };
}
