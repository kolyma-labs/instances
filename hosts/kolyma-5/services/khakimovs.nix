{
  outputs,
  pkgs,
  config,
  ...
}: {
  # Enable web server & proxy
  kolyma.www.hosts = {
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
}
