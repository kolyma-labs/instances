{
  lib,
  config,
  ...
}: {
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

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
