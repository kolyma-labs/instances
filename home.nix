{ inputs
, outputs
, username
, lib
, ...
}: {
  imports = [
    inputs.orzklv.homeModules.zsh
    inputs.orzklv.homeModules.helix
    inputs.orzklv.homeModules.nixpkgs
    inputs.orzklv.homeModules.topgrade
    inputs.orzklv.homeModules.packages
  ];

  # This is required information for home-manager to do its job
  home = {
    stateVersion = "24.05";
    username = username;
    homeDirectory = "/home/${username}";

    # Tell it to map everything in the `config` directory in this
    # repository to the `.config` in my home-manager directory
    file.".config" = {
      # source = ./configs/config;
      source = "${inputs.orzklv}/configs/config";
      recursive = true;
    };

    file.".local/share" = {
      source = ./configs/share;
      recursive = true;
    };

    # Don't check if home manager is same as nixpkgs
    enableNixpkgsReleaseCheck = false;
  };

  programs.topgrade.settings.linux = lib.mkForce {
    nix_arguments = "--flake github:kolyma-labs/instances";
    home_manager_arguments = [ "--flake" "github:kolyma-labs/instances" ];
  };

  # Let's enable home-manager
  programs.home-manager.enable = true;
}
