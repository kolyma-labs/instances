{
  pkgs,
  config,
  ...
}: let
  domain = "social.floss.uz";
in {
  config = {
    sops.secrets = {
      "mastodon/mail" = {
        owner = config.services.mastodon.user;
        key = "mail/password";
      };
    };

    services.mastodon = {
      enable = true;
      localDomain = domain;
      configureNginx = true;

      package = pkgs.mastodon;

      smtp = {
        port = 587;
        host = "smtp.mail.me.com";

        user = "sakhib.orzklv@icloud.com";
        passwordFile = config.sops.secrets."mastodon/mail".path;

        authenticate = true;
        fromAddress = "support@floss.uz";
      };

      streamingProcesses = 30;
      extraConfig = {
        MAX_CHARS = "1000";
      };
    };
  };
}
