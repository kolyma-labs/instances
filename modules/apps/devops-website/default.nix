{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.kolyma.apps.devops.website;
in {
  imports = [
    inputs.devops-book.nixosModules.server
  ];

  options = {
    kolyma.apps.devops.website = {
      enable = lib.mkEnableOption "devopsuzb's guide book";

      domain = lib.mkOption {
        type = lib.types.str;
        default = "devopsuzb.uz";
        description = "Domain name to host website under for.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.devops.book = {
      inherit (cfg) enable;
      port = 51008;
      proxy = {
        inherit (cfg) enable domain;
        proxy = "nginx";
      };
    };

    services.nginx.virtualHosts."devops-journey.uz" = {
      forceSSL = true;
      enableACME = true;
      globalRedirect = "devopsuzb.uz";
    };
  };
}
