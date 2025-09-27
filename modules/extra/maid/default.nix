{...}: {
  config = {
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };

    system.autoUpgrade = {
      enable = true;
      dates = "hourly";
      flags = [
        "-L" # print build logs
      ];
      # Reboot mode
      # allowReboot = true;
      # operation = "boot";
      # Switch mode
      allowReboot = false;
      operation = "switch";
      randomizedDelaySec = "10min";
      flake = "github:kolyma-labs/instances";
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
    };
  };
}
