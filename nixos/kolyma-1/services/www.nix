{
  outputs,
  pkgs,
  ...
}: {
  imports = [outputs.nixosModules.caddy];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns1.kolyma.uz"];
    hosts = {
      "cdn1.kolyma.uz" = {
        extraConfig = ''
          root * /srv/cdn
          file_server browse
        '';
      };

      "khakimovs.uz" = {
        serverAliases = ["www.khakimovs.uz"];
        extraConfig = ''
          root * ${pkgs.personal.khakimovs}/www
          @stripExtensions path_regexp strip (.*)\.(html)
          redir @stripExtensions {re.strip.1} 301
          file_server {
          	index index.html
          }
          try_files {path} {path}/ {path}.html
        '';
      };

      "niggerlicious.uz" = {
        serverAliases = ["www.niggerlicious.uz"];
        extraConfig = ''
          reverse_proxy 127.0.0.1:8100
        '';
      };
    };
  };
}
