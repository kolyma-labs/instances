{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.kolyma.apps.xinux.bot;
in
{
  imports = [
    inputs.xinuxmgr-bot.nixosModules.xinux.bot
  ];

  options = {
    kolyma.apps.xinux.bot = {
      enable = lib.mkEnableOption "Xinux manager bot";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "xinux/bot" = {
        format = "binary";
        owner = config.services.xinux.bot.user;
        sopsFile = ../../../secrets/xinux/bot.hell;
      };
    };

    services.xinux.bot = {
      enable = cfg.enable;

      token = config.sops.secrets."xinux/bot".path;

      webhook = {
        enable = true;
        proxy = "nginx";
        port = 51005;
        domain = "bot.xinux.uz";
      };
    };
  };
}
