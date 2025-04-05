{...}: {
  config = {
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };

    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      flags = [
        "-L" # print build logs
      ];
      allowReboot = true;
      operation = "boot";
      randomizedDelaySec = "10min";
      flake = "github:kolyma-labs/instances";
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
    };
  };
}
