{
  outputs,
  pkgs,
  ...
}: let
in {
  imports = [outputs.nixosModules.container];

  # Enable containerization
  services.containers = {
    enable = true;
    ports = [];

    instances = {};
  };
}
