{outputs, ...}: {
  imports = [outputs.nixosModules.container];

  # Enable containerization
  kolyma.containers = {
    enable = true;
    ports = [];

    instances = {};
  };
}
