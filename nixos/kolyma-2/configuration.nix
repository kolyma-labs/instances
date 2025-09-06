{
  inputs,
  outputs,
  ...
}: {
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
    outputs.nixosModules.users.kei
    outputs.nixosModules.users.sakhib
    outputs.nixosModules.users.shakhzod
    outputs.nixosModules.users.bahrom04
    outputs.nixosModules.users.aekinskjaldi

    # Import your deployed service list
    ./services

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Home Manager NixOS Module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Hostname of the system
  networking.hostName = "Kolyma-2";

  # Entirely disable hibernation
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Don't ask for password
  security.sudo.wheelNeedsPassword = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
