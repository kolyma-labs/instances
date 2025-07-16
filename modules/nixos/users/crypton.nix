{
  inputs,
  outputs,
  lib,
  ...
}: let
  username = "crypton";
in {
  config = {
    users.users = {
      "${username}" = {
        isNormalUser = true;
        # isAutist = true;
        # isKonchenniy = "definitely";
        description = "Crypton32";

        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID7gYfQFvXCw1cS5+18mDFeZnsvSlrGP/LZhBCZ6iix3 Crypton415"
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
