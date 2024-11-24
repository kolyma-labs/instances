{ outputs, ... }:
{
  imports = [ outputs.nixosModules.container ];

  # Enable containerization
  services.containers = {
    enable = true;

    instances = { };
  };
}
