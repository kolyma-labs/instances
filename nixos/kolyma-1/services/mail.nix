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
  };
  uzinocomSops = ../../../secrets/uzinfocom.yaml;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  sops.secrets = {
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
    "matrix/uzinfocom/mail/domirando" = {
      sopsFile = uzinocomSops;
      key = "mail/domirando/hashed";
    };
    "matrix/uzinfocom/mail/bemeritus" = {
      sopsFile = uzinocomSops;
      key = "mail/bemeritus/hashed";
    };
    "matrix/uzinfocom/mail/letrec" = {
      sopsFile = uzinocomSops;
      key = "mail/letrec/hashed";
    };
  };

  mailserver = {
    enable = true;
    fqdn = domains.uzinfocom.mail;
    domains = with domains; [
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
      "domirando@${domains.uzinfocom.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/uzinfocom/mail/domirando".path;
      };
      "bemeritus@${domains.uzinfocom.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/uzinfocom/mail/bemeritus".path;
      };
      "letrec@${domains.uzinfocom.main}" = {
        hashedPasswordFile = config.sops.secrets."matrix/uzinfocom/mail/letrec".path;
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
