{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.docs;
in {
  options = {
    kolyma.docs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable kolyma's instance docs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    documentation.nixos = {
      # Disable HTML documentation for NixOS modules, can cause issues with module overrides
      inherit (cfg) enable;

      # Fails for not providing custom doc rendering
      checkRedirects = false;

      # Why not gamble?
      includeAllModules = true;
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
