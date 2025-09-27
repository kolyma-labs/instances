{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.base;
in {
  imports = [
    # Bootloader
    ./boot

    # Network interface
    ./network

    # System Nixpkgs
    ./nixpkgs

    # Sops Nix
    ./secret

    # No Sleep
    ./power

    # Secure Shell
    ./ssh

    # System shell
    ./zsh
  ];

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
