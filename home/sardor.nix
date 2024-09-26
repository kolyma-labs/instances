{ inputs
, lib
, pkgs
, config
, outputs
, packages
, self
, ...
}: {
  imports = [
    outputs.homeManagerModules.zsh
    outputs.homeManagerModules.nixpkgs
    outputs.homeManagerModules.packages
  ];

  # This is required information for home-manager to do its job
  home = {
    stateVersion = "24.05";
    username = "sardor";
    homeDirectory = "/home/sardor";

    # Tell it to map everything in the `config` directory in this
    # repository to the `.config` in my home-manager directory
    file.".config" = {
      source = ../configs/config;
      recursive = true;
    };

    file.".local/share" = {
      source = ../configs/share;
      recursive = true;
    };

    # Don't check if home manager is same as nixpkgs
    enableNixpkgsReleaseCheck = false;
  };

  # Let's enable home-manager
  programs.home-manager.enable = true;
}
