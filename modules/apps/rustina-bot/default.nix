{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.kolyma.apps.rust-uz.bot;

  ownership = key: {
    inherit key;
    owner = config.services.rustina.user;
    sopsFile = ../../../secrets/rust-lang/bot.yaml;
  };
in {
  imports = [
    inputs.rustina-bot.nixosModules.bot
  ];

  options = {
    kolyma.apps.rust-uz.bot = {
      enable = lib.mkEnableOption "Rustina Manager bot";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "rust-lang/bot/github" = ownership "github";
      "rust-lang/bot/telegram" = ownership "telegram";
    };

    services.rustina = {
      enable = cfg.enable;

      tokens = {
        github = config.sops.secrets."rust-lang/bot/github".path;
        telegram = config.sops.secrets."rust-lang/bot/telegram".path;
      };

      webhook = {
        enable = true;
        proxy = "nginx";
        port = 51006;
        domain = "bot.rust-lang.uz";
      };
    };
  };
}
