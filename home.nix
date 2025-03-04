{
  inputs,
  # outputs,
  username,
  lib,
  ...
}: {
  imports = [
    inputs.orzklv.homeModules.zsh
    inputs.orzklv.homeModules.helix
    inputs.orzklv.homeModules.secret
    inputs.orzklv.homeModules.nixpkgs
    inputs.orzklv.homeModules.topgrade
    inputs.orzklv.homeModules.packages
    inputs.orzklv.homeModules.fastfetch
  ];

  # This is required information for home-manager to do its job
  home = {
    inherit username;
    stateVersion = "24.11";
    homeDirectory = "/home/${username}";

    # Tell it to map everything in the `config` directory in this
    # repository to the `.config` in my home-manager directory
    file.".local/share/fastfetch" = {
      source = "${inputs.orzklv}/configs/fastfetch";
      recursive = true;
    };

    # Don't check if home manager is same as nixpkgs
    enableNixpkgsReleaseCheck = false;
  };

  programs.topgrade.settings = {
    # Remove cache cleaninx as it deletes all derivations
    pre_commands = lib.mkForce {};

    # Target configuration link to another
    linux = lib.mkForce {
      nix_arguments = "--flake github:kolyma-labs/instances --option tarball-ttl 0";
    };
  };

  # Overwrite secrets file to current repo's
  sops.defaultSopsFile = lib.mkForce ./secrets/secrets.yaml;

  # Let's enable home-manager
  programs.home-manager.enable = true;
}
