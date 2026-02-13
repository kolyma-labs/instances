{
  config,
  outputs,
  ...
}:
{
  imports = [
    # Top level abstractions
    outputs.nixosModules.bind
    outputs.nixosModules.gate
    outputs.nixosModules.git
    outputs.nixosModules.mastodon
    outputs.nixosModules.searx
    outputs.nixosModules.web

    # Per app preconfigured abstractions
    outputs.nixosModules.apps.rustina-bot
    outputs.nixosModules.apps.xinuxmgr-bot
    outputs.nixosModules.apps.uzbek-net-website
    outputs.nixosModules.apps.uzinfocom-website
    outputs.nixosModules.apps.devops-website
  ];

  sops.secrets = {
    "git/database" = {
      sopsFile = ../../secrets/git/secrets.yaml;
      key = "database";
    };
    "git/mail" = {
      sopsFile = ../../secrets/mail.yaml;
      key = "mail/raw";
    };
    "git/key" = {
      format = "binary";
      sopsFile = ../../secrets/git/key.hell;
      path = "/etc/forgejo/ssh/id_forgejo";
    };
  };

  # Kolyma services
  kolyma = {
    # https://ns2.kolyma.uz
    www = {
      enable = true;
      instance = 2;
    };

    # bind://ns2.kolyma.uz
    nameserver = {
      enable = true;
      type = "slave";
    };

    # https://tarmoqchi.uz
    gate.enable = true;

    # https://git.floss.uz
    git = {
      enable = true;
      domain = "git.floss.uz";
      mail = config.sops.secrets."git/mail".path;
      database = config.sops.secrets."git/database".path;

      keys = {
        private = config.sops.secrets."git/key".path;
        public = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFa0lnjY2C0/n9Ka0ColrrQi7bIAF5+FpNW7aWJle2+5 admin@floss.uz";
      };
    };

    # https://social.floss.uz
    mastodon = {
      enable = true;
      domain = "floss.uz";
    };

    # search.floss.uz
    search.enable = true;

    # *://*
    apps = {
      # https://uzbek.net.uz
      uzbek-net.website.enable = true;

      # https://*.uzinfocom.uz
      uzinfocom = {
        # https://link.uzinfocom.uz
        social.enable = true;
        # https://oss.uzinfocom.uz
        website.enable = true;
      };

      # https://t.me/xinuxmgrbot
      xinux.bot.enable = true;

      # https://t.me/rustaceanbot
      rust-uz.bot.enable = true;

      # https://devopsuzb.uz
      devops.website.enable = true;
    };
  };
}
