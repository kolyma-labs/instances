{
  inputs,
  outputs,
  lib,
  ...
}: let
  username = "sakhib";

  hashedPassword = lib.strings.concatStrings [
    "$y$j9T$dsXOFHW"
    "CyplfRPiwsKu0l"
    "0$7YXPRLohyW8Q"
    "XfyITPP6Sag/l7"
    "XH3i7TO4uGByPK"
    "Bb2"
  ];
in {
  config = {
    users.users = {
      "${username}" = {
        inherit hashedPassword;
        isNormalUser = true;
        # isAutist = true;
        # isKonchenniy = "definitely";
        description = "Sokhibjon Orzikulov";

        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];

        openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
          builtins.readFile (
            builtins.fetchurl {
              url = "https://github.com/orzklv.keys";
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
