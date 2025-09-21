{
  outputs,
  pkgs,
  config,
  ...
}: {
  imports = [outputs.nixosModules.nginx];

  users.users.nginx.extraGroups = [config.users.groups.anubis.name];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns1.kolyma.uz"];
    hosts = {
      "cdn1.kolyma.uz" = {
        addSSL = true;
        enableACME = true;
        root = "/srv/cdn";
        extraConfig = ''
          autoindex on;
        '';
      };

      "cdn.xinux.uz" = {
        addSSL = true;
        enableACME = true;
        root = "/srv/xinux";
        extraConfig = ''
          autoindex on;
        '';
      };

      "khakimovs.uz" = {
        addSSL = true;
        enableACME = true;
        serverAliases = ["www.khakimovs.uz"];
        root = "${pkgs.personal.khakimovs}/www";

        locations."/".extraConfig = ''
          try_files $uri $uri/ $uri.html =404;
        '';

        locations."~ ^/(.*)\\.html$".extraConfig = ''
          rewrite ^/(.*)\\.html$ /$1 permanent;
        '';
      };
    };
  };
}
