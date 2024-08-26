{ config
, lib
, pkgs
, inputs
, ...
}: {
  config = {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L" # print build logs
      ];
      dates = "23:59";
      randomizedDelaySec = "10min";
    };
  };
}
