{
  config,
  inputs,
  ...
}: let
  domain = "floss.uz";
  server = "matrix.${domain}";
in {
  imports = [inputs.floss-website.nixosModules.server];

  # Enable website module
  services.floss-website = {
    enable = true;
    port = 8656;
    host = "127.0.0.1";

    proxy = {
      enable = false;
    };
  };

  services.www.hosts = {
    "${domain}" = {
      serverAliases = [
        "www.${domain}"
      ];
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

        handle {
          reverse_proxy ${config.services.floss-website.host}:${toString config.services.floss-website.port}
        }
      '';
    };
  };
}
