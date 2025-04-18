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
  };

  mailserver = {
    enable = true;
    fqdn = "mail.floss.uz";
    domains = ["floss.uz"];

    loginAccounts = {
      "admin@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."mail/floss/admin".path;
        aliases = ["postmaster@floss.uz"];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
