{ config, inputs, ... }: {
  imports = [
    inputs.xinux.nixosModules.xinux.bot
  ];

  sops.secrets = {
    "xinux/bot" = { };
  };

  # Enable xinux bots
  services.xinux.bot = {
    enable = true;
    token = config.sops.secrets."xinux/bot".path;

    webhook = {
      proxy = "caddy";
      domain = "xinuxmgr.xinux.uz";
      port = 8445;
    };
  };
}
