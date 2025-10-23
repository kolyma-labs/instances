{
  config,
  outputs,
  ...
}: {
  imports = [
    # Top level abstractions
    outputs.nixosModules.bind
    outputs.nixosModules.gate
    outputs.nixosModules.git
    outputs.nixosModules.mastodon
    outputs.nixosModules.web

    # Per app preconfigured abstractions
    outputs.nixosModules.apps.uzbek-net-website
    outputs.nixosModules.apps.uzinfocom-website
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
    # Enable web server & proxy
    www = {
      enable = true;
      instance = 2;
      anubis = true;
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";
    };

    # Tarmoqchi central
    gate.enable = true;

    # Forgejo server
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

    # Social mastodon
    mastodon = {
      enable = true;
      domain = "floss.uz";
    };

    # Deployed apps
    apps = {
      uzbek-net.website.enable = true;
      uzinfocom = {
        social.enable = true;
        website.enable = true;
      };
    };
  };
}
