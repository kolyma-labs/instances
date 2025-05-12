{outputs, ...}: {
  imports = [outputs.nixosModules.nginx];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns4.kolyma.uz"];
    no-default = true;
    hosts = {
      "cdn4.kolyma.uz" = {
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
        root = "/srv/cdn";
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
