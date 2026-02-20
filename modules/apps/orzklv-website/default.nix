{
  lib,
  inputs,
  config,
  ...
}:
let
  cfg = config.kolyma.apps.orzklv.website;
in
{
  imports = [
    inputs.orzklv-web.nixosModules.static
  ];

  options = {
    kolyma.apps.orzklv.website = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to host github:orzklv/web project in this server.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.orzklv-website = {
      enable = true;
      domain = "orzklv.uz";
    };
  };
}
