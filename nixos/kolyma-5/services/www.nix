{
  outputs,
  pkgs,
  config,
  ...
}: {
  imports = [outputs.nixosModules.web];

  users.users.nginx.extraGroups = [config.users.groups.anubis.name];

  # Enable web server & proxy
  kolyma.www = {
    enable = true;
    domain = "ns5.kolyma.uz";

    hosts = {
      # "cdn.xinux.uz" = {
      #   addSSL = true;
      #   enableACME = true;
      #   root = "/srv/xinux";
      #   extraConfig = ''
      #     autoindex on;
      #   '';
      # };

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
