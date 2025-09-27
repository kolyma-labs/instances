{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.kolyma.secrets;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options = {
    kolyma.secrets = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable sops secret manager.";
      };

      key = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/private/magadan";
        description = "Path where key is being guarded.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.keyFile = cfg.key;
      defaultSopsFormat = "yaml";
      defaultSopsFile = ../../../secrets/secrets.yaml;
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
