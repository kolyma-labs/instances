# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  outputs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # System related configs
    outputs.nixosModules.base
    outputs.nixosModules.extra
    outputs.nixosModules.users

    # Service oriented configs
    ./services.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # Hostname of the system
  networking.hostName = "Galitsky";

  kolyma = {
    # Users of system
    accounts.teams = with lib.camps; [owners];
  };

  # NVIDIA driver support
  services.xserver.videoDrivers = ["nvidia"];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?
}
