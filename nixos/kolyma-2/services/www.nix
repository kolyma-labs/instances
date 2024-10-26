{ outputs, ... }: {
  imports = [
    outputs.nixosModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns2.kolyma.uz" ];
    hosts = {
      "mail.kolyma.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8460
        '';
      };

      "old.kolyma.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8450
        '';
      };
    };
  };
}
