{outputs, ...}: {
  imports = [outputs.nixosModules.nginx];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns4.kolyma.uz"];
    hosts = {};
  };
}
