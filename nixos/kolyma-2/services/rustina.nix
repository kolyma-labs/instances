{
  config,
  inputs,
  ...
}: {
  imports = [inputs.rustina.nixosModules.bot];

  sops.secrets = {
    "rustina/telegram" = {
      owner = config.services.rustina.user;
    };
    "rustina/github" = {
      owner = config.services.rustina.user;
    };
  };

  # Enable xinux bots
  services.rustina = {
    enable = true;
    tokens = {
      telegram = config.sops.secrets."rustina/telegram".path;
      github = config.sops.secrets."rustina/github".path;
    };

    webhook = {
      enable = true;
      proxy = "caddy";
      domain = "bot.rust-lang.uz";
      port = 8446;
    };
  };
}
