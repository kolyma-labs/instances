{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.ssh
    outputs.nixosModules.zsh
    outputs.nixosModules.boot
    outputs.nixosModules.data
    outputs.nixosModules.maid
    outputs.nixosModules.motd
    outputs.nixosModules.root
    outputs.nixosModules.secret
    outputs.nixosModules.network
    outputs.nixosModules.nixpkgs

    # User configs
    outputs.nixosModules.users.sakhib

    # Import your deployed service list
    ./services

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Home Manager NixOS Module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Hostname of the system
  networking.hostName = "Kolyma-1";

  # Don't ask for password
  security.sudo.wheelNeedsPassword = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
