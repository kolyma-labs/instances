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

    enableSubmission = true;
    enableSubmissionSsl = true;

    loginAccounts = {
      "admin@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/admin".path;
        aliases = ["postmaster@floss.uz" "orzklv@floss.uz"];
      };
      "support@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/support".path;
        aliases = ["noreply@floss.uz"];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
