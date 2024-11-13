{ pkgs
, inputs
, outputs
, lib
, config
, packages
, ...
}:
let
  username = "hsv";
in
{
  config = {
    users.users = {
      "${username}" = {
        isNormalUser = true;
        description = "HSVSphere";
        initialPassword = "F1st1ng15300Buck$!?";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVkWUQ6Z4OK539tore/R5wnueNPPaX532RUAld8UOCo"
        ];
        extraGroups = [ "docker" "admins" ];
      };
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs outputs; };
      users = {
        # Import your home-manager configuration
        "${username}" = import ../../../home.nix {
          inherit inputs outputs username lib;
        };
      };
    };
  };
}
