{
  inputs,
  config,
  domains,
}: let
  domain = domains.main;
  sopsFile = ../../../../secrets/efael.yaml;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  sops.secrets = {
    "matrix/mail/admin" = {
      inherit sopsFile;
      key = "mail/admin/hashed";
    };
    "matrix/mail/support" = {
      inherit sopsFile;
      key = "mail/support/hashed";
    };
  };

  mailserver = {
    enable = true;
    fqdn = domains.mail;
    domains = [domain];

    localDnsResolver = false;

    fullTextSearch = {
      enable = true;
      # index new email as they arrive
      autoIndex = true;
      # forcing users to write body
      enforced = "body";
    };

    # Generating hashed passwords:
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "admin@${domain}" = {
        hashedPasswordFile = config.sops.secrets."matrix/mail/admin".path;
        aliases = ["postmaster@${domain}" "orzklv@${domain}"];
      };
      "support@${domain}" = {
        hashedPasswordFile = config.sops.secrets."matrix/mail/support".path;
      };
      "noreply@${domain}" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."matrix/mail/support".path;
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
