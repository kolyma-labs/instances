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

    # Root user
    ./root

    # Sops Nix
    ./secret

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
    # Networking module
    network.enable = true;

    # Bootloader module
    boot.bios.enable = true;
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
