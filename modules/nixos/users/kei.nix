{
  pkgs,
  inputs,
  outputs,
  lib,
  config,
  packages,
  ...
}:
let
  username = "kei";
in
{
  config = {
    users.users = {
      "${username}" = {
        isNormalUser = true;
        description = "Kei Thelissimus";
        initialPassword = "AlwaysLam6daBlyat!!!";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGfrN6xvFmo+S59KksbxSpFxOVDBzGrkPfuFK4qDPmk2 thelissimus@tuta.io"
        ];
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "admins"
        ];
      };
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs outputs;
      };
      users = {
        # Import your home-manager configuration
        "${username}" = import ../../../home.nix {
          inherit
            inputs
            outputs
            username
            lib
            ;
        };
      };
    };
  };
}
