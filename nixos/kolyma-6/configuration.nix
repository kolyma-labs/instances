{
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # System related configs
    outputs.nixosModules.base
    outputs.nixosModules.extra
    outputs.nixosModules.users

    # Service oriented configs
    outputs.nixosModules.web
    outputs.nixosModules.bind

    # Import your deployed service list
    ./services

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # Hostname of the system
  networking.hostName = "Kolyma-6";

  # Entirely disable hibernation
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  kolyma = {
    # Users of system
    accounts.teams = [
      lib.camps.uzinfocom
    ];

    # Web Server & Proxy
    www = {
      enable = true;
      domain = "ns6.kolyma.uz";
      anubis = true;
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
  system.stateVersion = "24.11";
}
