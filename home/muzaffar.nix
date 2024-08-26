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
    outputs.homeManagerModules.helix
    outputs.homeManagerModules.nixpkgs
    outputs.homeManagerModules.packages
  ];

  # This is required information for home-manager to do its job
  home = {
    stateVersion = "24.05";
    username = "muzaffar";
    homeDirectory = "/home/muzaffar";

    # Don't check if home manager is same as nixpkgs
    enableNixpkgsReleaseCheck = false;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Let's enable home-manager
  programs.home-manager.enable = true;
}
