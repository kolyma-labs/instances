{ outputs, ... }: {
  imports = [
    outputs.serverModules.container
  ];

  # Enable containerization
  services.containers = {
    enable = true;
    instances = { };
  };
}
