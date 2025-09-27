{inputs, ...}: {
  imports = [inputs.efael-website.nixosModules.server];

  # Enable xinux bots
  services.efael.website = {
    enable = true;
    port = 8442;

    proxy = {
      enable = true;
      domain = "efael.net";
      proxy = "nginx";
    };
  };
}
