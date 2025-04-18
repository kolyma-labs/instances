{
  inputs,
  config,
  pkgs,
  ...
}: let
  # secret-management = {
  #   owner = config.users.users.stalwart-mail.name;
  # };
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  sops.secrets = {
    "mail/floss/admin" = {};
    "mail/floss/support" = {};
  };

  mailserver = {
    enable = true;
    fqdn = "mail.floss.uz";
    domains = ["floss.uz"];

    localDnsResolver = false;

    fullTextSearch = {
      enable = true;
      # index new email as they arrive
      autoIndex = true;
      # this only applies to plain text attachments, binary attachments are never indexed
      indexAttachments = true;
      enforced = "body";
    };

    loginAccounts = {
      "admin@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/admin".path;
        aliases = ["postmaster@floss.uz" "orzklv@floss.uz"];
      };
      "support@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/support".path;
      };
      "noreply@floss.uz" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."mail/floss/support".path;
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
