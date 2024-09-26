{ outputs, ... }: {
  imports = [
    outputs.serverModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns4.kolyma.uz" ];
    hosts = { };
  };
}
