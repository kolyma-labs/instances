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
    "mail/floss/admin/hashed" = {};
    "mail/floss/support/hashed" = {};
    "mail/floss/raxmatov/hashed" = {};
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

    # Generating hashed passwords:
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "admin@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/admin/hashed".path;
        aliases = ["postmaster@floss.uz" "orzklv@floss.uz"];
      };
      "support@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/support/hashed".path;
        aliases = ["developers@floss.uz" "maintainers@floss.uz"];
      };
      "noreply@floss.uz" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."mail/floss/support/hashed".path;
      };
      "b.raxmatov@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/raxmatov/hashed".path;
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
