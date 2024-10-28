{ config, inputs, ... }: {
  imports = [
    inputs.xinux.nixosModules.xinux.bot
  ];

  sops.secrets = {
    "xinux/bot" = {
      owner = config.services.xinux.bot.user;
    };
  };

  # Enable xinux bots
  services.xinux.bot = {
    enable = true;
    token = config.sops.secrets."xinux/bot".path;

    webhook = {
      enable = true;
      proxy = "caddy";
      domain = "xinuxmgr.xinux.uz";
      port = 8445;
    };
  };
}
