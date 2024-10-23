{ inputs, ... }: {
  imports = [
    inputs.xinux.nixosModules.xinuxbots
  ];

  # Enable xinux bots
  services.xinuxbots = {
    enable = true;
    secret = /srv/bots/xinuxmgr.env;
  };
}
