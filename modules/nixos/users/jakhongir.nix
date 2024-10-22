{ pkgs
, inputs
, outputs
, lib
, config
, packages
, ...
}:
let
  username = "jakhongir";
in
{
  config = {
    users.users = {
      "${username}" = {
        isNormalUser = true;
        description = "Jakhongir Ravshanov";
        initialPassword = "F1st1ng15300Buck$!?";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPv6diUR/ACrAaO5ILnPYqbj+wqZIUZTYKr0ccVnftfs jony@jonys-arch"
        ];
        extraGroups = [ "docker" "admins" ];
      };
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs outputs; };
      users = {
        # Import your home-manager configuration
        "${username}" = import ../../../home.nix {
          inherit inputs outputs username;
        };
      };
    };
  };
}
