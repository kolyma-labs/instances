{
  outputs,
  pkgs,
  config,
  ...
}: {
  imports = [outputs.nixosModules.nginx];

  # Enable web server & proxy
  services.www = {
    enable = true;
  };
}
