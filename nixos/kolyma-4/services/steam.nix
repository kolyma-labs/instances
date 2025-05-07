{
  # inputs,
  pkgs,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  services.www.hosts = {
    "cache.kolyma.uz" = {
      addSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8501";
        extraConfig = "proxy_ssl_server_name on;";
      };
    };
  };
}
