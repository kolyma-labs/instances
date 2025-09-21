{
  inputs,
  config,
  pkgs,
  ...
}: let
  domain = "floss.uz";
  sopsFile = ../../../secrets/floss.yaml;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  sops.secrets = {
    "snm/mail/admin" = {
      inherit sopsFile;
      key = "mail/admin/hashed";
    };
    "snm/mail/support" = {
      inherit sopsFile;
      key = "mail/support/hashed";
    };
    "snm/mail/raxmatov" = {
      inherit sopsFile;
      key = "mail/support/hashed";
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.${domain}";
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
        hashedPasswordFile = config.sops.secrets."snm/mail/admin".path;
        aliases = ["postmaster@${domain}" "orzklv@${domain}"];
      };
      "support@${domain}" = {
        hashedPasswordFile = config.sops.secrets."snm/mail/support".path;
        aliases = ["developers@${domain}" "maintainers@${domain}"];
      };
      "noreply@${domain}" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."snm/mail/support".path;
      };
      "b.raxmatov@floss.uz" = {
        hashedPasswordFile = config.sops.secrets."snm/mail/raxmatov".path;
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
