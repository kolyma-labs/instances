{
  inputs,
  config,
  domains,
}: let
  domain = domains.main;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  sops.secrets = {
    "mail/efael/admin/hashed" = {};
    "mail/efael/support/hashed" = {};
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
        hashedPasswordFile = config.sops.secrets."mail/efael/admin/hashed".path;
        aliases = ["postmaster@${domain}" "orzklv@${domain}"];
      };
      "support@${domain}" = {
        hashedPasswordFile = config.sops.secrets."mail/efael/support/hashed".path;
      };
      "noreply@${domain}" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."mail/efael/support/hashed".path;
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
