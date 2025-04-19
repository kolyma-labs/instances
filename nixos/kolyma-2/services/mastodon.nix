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
        key = "mail/floss/support/raw";
      };
    };

    services.mastodon = {
      enable = true;
      localDomain = domain;
      configureNginx = true;

      package = pkgs.mastodon;

      smtp = {
        port = 587;
        host = "mail.floss.uz";

        user = "noreply@floss.uz";
        passwordFile = config.sops.secrets."mastodon/mail".path;

        authenticate = true;
        fromAddress = "noreply@floss.uz";
      };

      streamingProcesses = 30;
      extraConfig = {
        MAX_CHARS = "1000";
      };
    };
  };
}
