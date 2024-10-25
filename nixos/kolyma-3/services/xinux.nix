{ inputs, ... }: {
  imports = [
    inputs.xinux.nixosModules.xinux.bot
  ];

  # Enable xinux bots
  services.xinux.bot = {
    enable = true;
    secret = /srv/bots/xinuxmgr.env;
  };
}
