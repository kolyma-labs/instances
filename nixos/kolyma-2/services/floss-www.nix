{
  config,
  inputs,
  ...
}: {
  imports = [inputs.floss-website.nixosModules.server];

  # Enable website module
  services.floss-website = {
    enable = true;
    port = 8445;
    host = "127.0.0.1";

    proxy = {
      enable = true;
      proxy = "caddy";
      domain = "floss.uz";
    };
  };
}
