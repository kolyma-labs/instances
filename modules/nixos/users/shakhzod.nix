{
  inputs,
  outputs,
  lib,
  ...
}: let
  username = "shakhzod";

  hashedPassword = lib.strings.concatStrings [
    "$y$j9T$mi9V."
    "JCa4o3.QO2X2"
    "8vJo1$KzXKjk"
    "/5sN4lbsvF8B"
    "IEIwhKCL34e0"
    "gJxZEe.MMoT1"
    "B"
  ];
in {
  config = {
    users.users = {
      "${username}" = {
        inherit hashedPassword;
        isNormalUser = true;
        # isAutist = true;
        # isKonchenniy = "definitely";
        description = "Shakhzod Kudratov";

        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];

        openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
          builtins.readFile (
            builtins.fetchurl {
              url = "https://github.com/shakhzodkudratov.keys";
              sha256 = "0gnabwywc19947a3m4702m7ibhxmc5s4zqbhsydb2wq92k6qgh6g";
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
