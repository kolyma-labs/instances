{
  inputs,
  config,
  ...
}: let
  domains = {
    uzinfocom = rec {
      main = "oss.uzinfocom.uz";
      mail = "mail.${main}";
    };
    efael = rec {
      main = "efael.net";
      mail = "mail.${main}";
    };
  };
  efaelSops = ../../../secrets/efael.yaml;
  uzinocomSops = ../../../secrets/uzinfocom.yaml;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  sops.secrets = {
    "matrix/efael/mail/admin" = {
      sopsFile = efaelSops;
      key = "mail/admin/hashed";
    };
    "matrix/efael/mail/support" = {
      sopsFile = efaelSops;
      key = "mail/support/hashed";
    };
    "matrix/uzinfocom/mail/admin" = {
      sopsFile = uzinocomSops;
      key = "mail/admin/hashed";
    };
    "matrix/uzinfocom/mail/support" = {
      sopsFile = uzinocomSops;
      key = "mail/support/hashed";
    };
    "matrix/uzinfocom/mail/bahrom04" = {
      sopsFile = uzinocomSops;
      key = "mail/bahrom04/hashed";
    };
  };

  mailserver = {
    enable = true;
    fqdn = domains.uzinfocom.mail;
    domains = with domains; [
      efael.main
      uzinfocom.main
    ];

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
      # ================================= #
      #               Efael               #
      # ================================= #
      "admin@${domains.efael.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/efael/mail/admin".path;
        aliases = ["postmaster@${domains.efael.main}" "orzklv@${domains.efael.main}"];
      };
      "support@${domains.efael.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/efael/mail/support".path;
      };
      "noreply@${domains.efael.main}" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."matrix/efael/mail/support".path;
      };

      # ================================= #
      #              Uzinfocom            #
      # ================================= #
      "admin@${domains.uzinfocom.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/uzinfocom/mail/admin".path;
        aliases = ["postmaster@${domains.uzinfocom.main}" "orzklv@${domains.uzinfocom.main}"];
      };
      "support@${domains.uzinfocom.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/uzinfocom/mail/support".path;
      };
      "bahrom04@${domains.uzinfocom.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/uzinfocom/mail/bahrom04".path;
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
