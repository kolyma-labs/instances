{outputs, ...}: {
  imports = [outputs.nixosModules.nginx];

  # Enable web server & proxy
  services.www = {
    enable = true;
    domain = "slave.uz";
    alias = [
      "ns3.kolyma.uz"
    ];
    hosts = {
      "sabine.uz" = {
        addSSL = true;
        enableACME = true;
        serverAliases = ["www.sabine.uz"];

        locations."/" = {
          proxyPass = "http://127.0.0.1:8100";
          proxyWebsockets = true;
          extraConfig = "proxy_ssl_server_name on;";
        };
      };
    };
  };
}
