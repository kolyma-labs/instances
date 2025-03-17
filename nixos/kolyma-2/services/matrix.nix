{
  lib,
  pkgs,
  config,
  ...
}: let
  server_name = "floss.uz";
  secure_token = "niggerlicious";
  matrix_hostname = "matrix.${server_name}";
in {
  options = {
    services.matrix-conduit.settings = lib.mkOption {
      apply = old:
        old
        // (
          if (old.global ? "unix_socket_path")
          then {global = builtins.removeAttrs old.global ["address" "port"];}
          else {}
        );
    };
  };

  config = {
    systemd.services.conduit.serviceConfig.RestrictAddressFamilies = ["AF_UNIX"];

    services.matrix-conduit = {
      enable = true;
      settings.global = {
        address = "127.0.0.1";
        allow_registration = true;
        registration_token = "${secure_token}";
        database_backend = "rocksdb";
        port = 6167;
        server_name = "${server_name}";
        trusted_servers = [
          "nixos.org"
          "matrix.org"
          "mozilla.org"
          "puppygock.gay"
        ];
      };
      package = pkgs.conduwuit;
    };

    services.www.hosts = {
      "${server_name}" = {
        extraConfig = ''
          handle_path /.well-known/matrix/client {
            header Content-Type application/json
            header Access-Control-Allow-Origin "*"

            respond `{
              "m.homeserver": {
                "base_url": "https://${matrix_hostname}"
              }
            }`
          }

          handle_path /.well-known/matrix/server {
            header Content-Type application/json

            respond `{
              "m.server": "${matrix_hostname}"
            }`
          }

          handle {
            redir https://www.{host}{uri} permanent
          }
        '';
      };

      "${matrix_hostname}" = {
        extraConfig = ''
          reverse_proxy /_matrix/* ${config.services.matrix-conduit.settings.global.address}:${toString config.services.matrix-conduit.settings.global.port}
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
  };
}
