{ outputs, ... }: {
  imports = [
    outputs.serverModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;

    hosts = { };
  };
}
