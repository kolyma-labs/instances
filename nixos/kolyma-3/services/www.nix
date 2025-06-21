{outputs, ...}: {
  imports = [outputs.nixosModules.nginx];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns3.kolyma.uz"];
    no-default = true;
    hosts = {
      "cdn3.kolyma.uz" = {
        addSSL = true;
        enableACME = true;
        root = "/srv/cdn";
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
