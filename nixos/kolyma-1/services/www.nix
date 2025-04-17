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
      };

      "khakimovs.uz" = {
        addSSL = true;
        enableACME = true;
        serverAliases = ["www.khakimovs.uz"];
        root = "${pkgs.personal.khakimovs}/www";

        location."~ ^/(.*)\.html$".extraConfig = ''
          return 301 /$1;
        '';

        location."/".extraConfig = ''
          try_files $uri $uri/ $uri.html =404;
        '';
      };

      "niggerlicious.uz" = {
        addSSL = true;
        enableACME = true;
        serverAliases = ["www.niggerlicious.uz"];
        proxyPass = "http://127.0.0.1:8100";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;";
      };
    };
  };
}
