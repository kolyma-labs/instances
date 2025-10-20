{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.base;
in {
  imports =
    builtins.readDir ./.
    |> builtins.attrNames
    |> builtins.filter (m: m != "default.nix")
    |> builtins.filter (m: m != "readme.md")
    |> builtins.map (m: ./. + "/${m}");

  options = {
    kolyma.base = {
      enable = lib.options.mkOption {
        default = true;
        example = false;
        description = "Whether to configure base system.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    kolyma = {
      # Networking Module
      network.enable = true;

      # Bootloader Module
      boot.enable = true;

      # Preconfigured Nixpkgs
      nixpkgs.enable = true;

      # Secret Management
      secrets.enable = true;

      # Remote shell
      remote.enable = true;

      # Power Management
      power.enable = true;

      # Custom ZSH
      shell.enable = true;
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
