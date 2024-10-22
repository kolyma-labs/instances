{ outputs, ... }: {
  imports = [
    outputs.nixosModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns4.kolyma.uz" ];
    hosts = { };
  };
}
