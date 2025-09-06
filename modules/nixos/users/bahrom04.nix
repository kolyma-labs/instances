{
  inputs,
  outputs,
  lib,
  ...
}: let
  username = "bahrom04";
in {
  config = {
    users.users = {
      "${username}" = {
        isNormalUser = true;
        # isAutist = true;
        # isKonchenniy = "definitely";
        description = "Bakhrom Magdiyev";

        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGq3w7lLgdOzCVXp2Y/bec3ZPcdKvq4f7AE6qVyiH9Cm magdiyevbahrom@gmail.com"
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
        "${username}" = import ../../../home.nix {
          inherit inputs outputs username lib;
        };
      };
    };
  };
}
