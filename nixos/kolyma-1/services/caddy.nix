{ outputs, ... }: {
  imports = [
    outputs.nixosModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns1.kolyma.uz" ];
    hosts = {
      "cdn.kolyma.uz" = {
        extraConfig = ''
          root * /srv/cdn
          file_server browse
        '';
      };
    };
  };
}
