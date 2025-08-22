{
  inputs,
  outputs,
  lib,
  ...
}: let
  username = "aekinskjaldi";

  hashedPassword = lib.strings.concatStrings [
    "$y$j9T$VIu7tUhSD.zJlTG9D49rK/$biwcrfsI/RAZBKxpa4qOTI/777TNv0IwPYWOeJN.J8B"
  ];
in {
  config = {
    users.users = {
      "${username}" = {
        inherit hashedPassword;
        isNormalUser = true;
        # isAutist = true;
        # isKonchenniy = "definitely";
        description = "aekinskjaldi";

        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];

        openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
          builtins.readFile (
            builtins.fetchurl {
              url = "https://github.com/aekinskjaldi.keys";
              sha256 = "05rvkkk382jh84prwp4hafnr3bnawxpkb3w6pgqda2igia2a4865";
            }
          )
        );
      };
    };

    home-manager = {
      backupFileExtension = "hbak";

      extraSpecialArgs = {
        inherit inputs outputs;
      };

      users = {
        # Import your home-manager configuration
        "${username}" = import ../../../home.nix {
          inherit inputs outputs username lib;
        };
      };
    };
  };
}
