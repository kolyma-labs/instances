{
  config,
  inputs,
  ...
}: let
  domain = "floss.uz";
  alt-domain = "foss.uz";
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
        "${alt-domain}"
        "www.${alt-domain}"
      ];

      locations."= /.well-known/matrix/client" = {
        extraConfig = ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
          return 200 '{"m.homeserver": {"base_url": "https://your.domain.com"}}';
        '';
      };

      locations."= /.well-known/matrix/server" = {
        extraConfig = ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
          return 200 '{"m.server": "your.domain.com:443"}';
        '';
      };

      locations."/" = {
        proxyPass = "http://${config.services.floss-website.host}:${toString config.services.floss-website.port}";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
