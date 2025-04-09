{
  config,
  inputs,
  ...
}: let
  domain = "devops-journey.uz";
in {
  imports = [inputs.devops-journey.nixosModules.server];

  # Enable website module
  services.devops-journey = {
    enable = true;
    port = 8657;
    host = "127.0.0.1";

    proxy = {
      inherit domain;
      enable = true;
      proxy = "caddy";
      aliases = ["www.${domain}"];
    };
  };
}
