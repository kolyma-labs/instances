{
  inputs,
  outputs,
  ...
}: {
  imports = [
    # System related configs
    outputs.nixosModules.base
    outputs.nixosModules.extra

    # Service oriented configs
    outputs.nixosModules.web
    outputs.nixosModules.bind

    # User configs
    outputs.nixosModules.users.sakhib
    outputs.nixosModules.users.shakhzod
    outputs.nixosModules.users.bahrom04

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # =============================== #
  #  System related configurations  #
  # =============================== #

  # Hostname of the system
  networking.hostName = "Kolyma-1";

  # Entirely disable hibernation
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Don't ask for password
  security.sudo.wheelNeedsPassword = false;

  # Kolyma services
  kolyma = {
    # Web Server & Proxy
    www = {
      enable = true;
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "master";

      slaves = [
        # Kolyma GK-2
        "37.27.60.37"
        "2a01:4f9:3081:2e04::2"

        # Kolyma GK-5
        "167.235.96.40"
        "2a01:4f8:2190:2914::2"

        # Kolyma GK-6
        "65.109.74.214"
        "2a01:4f9:3071:31ce::2"
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
