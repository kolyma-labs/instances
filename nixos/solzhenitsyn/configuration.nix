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

  # Kolyma services
  kolyma = {
    # Enable web server & proxy
    www = {
      enable = true;
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";

      masters = [
        # Kolyma GK-1
        "37.27.67.190"
        "2a01:4f9:3081:3518::2"
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
