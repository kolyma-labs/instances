{ outputs, ... }: {
  imports = [
    outputs.nixosModules.nginx
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns1.kolyma.uz" ];
    hosts = {
      "cdn.kolyma.uz" = {
        forceSSL = true;
        enableACME = true;
        root = "/srv/cdn";
      };
    };
  };
}
