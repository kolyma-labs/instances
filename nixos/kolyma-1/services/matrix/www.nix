{inputs, ...}: {
  imports = [inputs.efael-website.nixosModules.server];

  # Enable xinux bots
  services.efael.website = {
    enable = true;
    proxy.enable = false;
    port = 8442;
  };
}
