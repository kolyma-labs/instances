{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.ssh
    outputs.nixosModules.zsh
    outputs.nixosModules.boot
    outputs.nixosModules.data
    outputs.nixosModules.maid
    outputs.nixosModules.motd
    outputs.nixosModules.network
    outputs.nixosModules.nixpkgs

    # User configs
    outputs.nixosModules.users.sakhib
    outputs.nixosModules.users.sardor
    outputs.nixosModules.users.shakhzod
    outputs.nixosModules.users.muzaffar
    outputs.nixosModules.users.jakhongir

    # Import your deployed service list
    ./services.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Home Manager NixOS Module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Hostname of the system
  networking.hostName = "Kolyma-3";

  # Entirely disable hibernation
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Don't ask for password
  security.sudo.wheelNeedsPassword = false;

  # To be able to SSH into the system on emergency
  users.users.root.openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAGqU+JleLM0T44P2quirtLPrhFExOi6EOe0GYXkTFcTSjhw9LqiuX1/FbqNdKTaP9k6CdV3xc/8Z5wxbNOhpcPi9XLoupv9oNyIew7QYl+ZoAck6/qPsM7uptGYCwo0/ErzPNLd3ERD3KT1axCqrI6rWJ+JFOMAPtGeAZZxIedksViZ5SuNhpzXCIzS2PACqDTxFj7JwXK/pQ200h9ZS0MSh7iLKggXQfRVDndJxRnVY69NmbRa4MqkjgyxqWSDbqrDAXuTHpqKJ5kpXJ6p2a82EIHcCwXXpEmLwKxatxWJWJb9nurm3aS74BYmT3pRVVSPC6n5a2LWN9GxzvVh3AXXZtWGvjXSqBxHdSyUoDPuZnDneycdRC5vs6I1jSGTyDFdc4Etq1M5uUYb6SqCjJIBvTNqVnOf8nzFwl/ENvc8sbIVtILgAbBdwDiiQSu8xppqWMZfkQJy+uI5Ok7TZ8o5rGIblzfKyTiljCQb7RO7Klg3TwysetREn8ZEykBx0= This world soon will cherish into my darkness of my madness'' ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
