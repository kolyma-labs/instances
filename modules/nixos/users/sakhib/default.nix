{
  inputs,
  outputs,
  lib,
  ...
}: let
  username = "sakhib";

  password =
    builtins.replaceStrings
    ["\n"] [""] (builtins.readFile ./password);
in {
  config = {
    users.users = {
      "${username}" = {
        isNormalUser = true;
        description = "Sokhibjon Orzikulov";
        hashedPassword = password;
        openssh.authorizedKeys.keys = [(builtins.readFile ./id_rsa.pub)];
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];
      };
    };

    home-manager = {
      backupFileExtension = "hbak";

      extraSpecialArgs = {
        inherit inputs outputs;
      };

      users = {
        # Import your home-manager configuration
        "${username}" = import ../../../../home.nix {
          inherit inputs outputs username lib;
        };
      };
    };
  };
}
