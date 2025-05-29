{
  pkgs,
  config,
  ...
}: let
  domain = "floss.uz";
  sopsFile = ../../../secrets/floss.yaml;
in {
  config = {
    sops.secrets = {
      "mastodon/mail" = {
        inherit sopsFile;
        owner = config.services.mastodon.user;
        key = "mail/support/raw";
      };
    };

    services.mastodon = {
      enable = true;
      localDomain = "social.${domain}";
      configureNginx = true;

      package = pkgs.mastodon;

      smtp = {
        port = 587;
        host = "mail.${domain}";

        user = "noreply@${domain}";
        passwordFile = config.sops.secrets."mastodon/mail".path;

        authenticate = true;
        fromAddress = "noreply@${domain}";
      };

      streamingProcesses = 30;
      extraConfig = {
        MAX_CHARS = "1000";
      };
    };
  };
}
