{
  lib,
  inputs,
  config,
  ...
}:
let
  cfg = config.kolyma.apps.uzbek-net.website;
in
{
  imports = [
    inputs.uzbek-net-website.nixosModules.server
  ];

  options = {
    kolyma.apps.uzbek-net.website = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to host github:uzbek-net/website project in this server.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "uzbek.net.uz";
        example = "example.com";
        description = "Domain for the website to be associated with.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.uzbek-net.website = {
      enable = true;
      port = 51002;

      proxy = {
        enable = true;
        inherit (cfg) domain;
      };
    };
  };
}
