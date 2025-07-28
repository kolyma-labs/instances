{
  outputs,
  pkgs,
  ...
}: {
  imports = [outputs.nixosModules.nginx];

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

      "niggerlicious.uz" = {
        addSSL = true;
        enableACME = true;
        serverAliases = ["www.niggerlicious.uz"];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8100";
          proxyWebsockets = true;
          extraConfig =
            "proxy_ssl_server_name on;"
            + "proxy_pass_header Authorization;";
        };
      };
    };
  };
}
