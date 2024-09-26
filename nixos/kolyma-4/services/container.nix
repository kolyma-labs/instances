{ outputs, ... }: {
  imports = [
    outputs.serverModules.container
  ];

  # Enable Nameserver hosting
  services.containers = {
    enable = true;
    instances = { };
    ports = [ ];
  };
}
