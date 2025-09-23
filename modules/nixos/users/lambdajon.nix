{
  inputs,
  outputs,
  lib,
  ...
}: let
  username = "lambdajon";

  hashedPassword = lib.strings.concatStrings [
    "$6$3JI5jcc8ttUHS3Jg$H/LACxCqw94BvJazHFc/8luEditd10VOe"
    "47FUKfj7.GrJq4Q92kLl0sfEjS1CcBSu4gNnvK7V4MnJtrJogcnm."
  ];
in {
  config = {
    users.users = {
      "${username}" = {
        inherit hashedPassword;
        isNormalUser = true;

        description = "Lambdajon";

        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];

        openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
          builtins.readFile (
            builtins.fetchurl {
              url = "https://github.com/lambdajon.keys";
              sha256 = "440dac32fb3ecd060c17f78ad7c34422fefaaccf525c75c3c8dfd5ce86ef516e";
            }
          )
        );
      };
    };

    home-manager = {
      backupFileExtension = "baka";

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
