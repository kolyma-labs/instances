{
  pkgs,
  config,
  ...
}: let
  domain = "social.floss.uz";
in {
  config = {
    sops.secrets = {
      "mastodon/smtp" = {
        owner = config.services.mastodon.user;
      };
    };

    services.mastodon = {
      enable = true;
      localDomain = domain;

      smtp = {
        port = 587;
        host = "smtp.mail.me.com";

        user = "sakhib.orzklv@icloud.com";
        passwordFile = config.sops.secrets."mastodon/smtp".path;

        authenticate = true;
        fromAddress = "support@floss.uz";
      };

      streamingProcesses = 30;
      extraConfig.SINGLE_USER_MODE = "true";
    };

    users.users.caddy.extraGroups = ["mastodon"];

    services.www.hosts = {
      ${domain} = {
        extraConfig = ''
          handle_path /system/* {
              file_server * {
                  root /var/lib/mastodon/public-system
              }
          }

          handle /api/v1/streaming/* {
              reverse_proxy  unix//run/mastodon-streaming/streaming.socket
          }

          route * {
              file_server * {
              root ${pkgs.mastodon}/public
              pass_thru
              }
              reverse_proxy * unix//run/mastodon-web/web.socket
          }

          handle_errors {
              root * ${pkgs.mastodon}/public
              rewrite 500.html
              file_server
          }

          encode gzip

          header /* {
              Strict-Transport-Security "max-age=31536000;"
          }
          header /emoji/* Cache-Control "public, max-age=31536000, immutable"
          header /packs/* Cache-Control "public, max-age=31536000, immutable"
          header /system/accounts/avatars/* Cache-Control "public, max-age=31536000, immutable"
          header /system/media_attachments/files/* Cache-Control "public, max-age=31536000, immutable"
        '';
      };
    };
  };
}
