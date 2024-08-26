{ pkgs
, inputs
, outputs
, lib
, config
, packages
, ...
}: {
  config = {
    users.users = {
      muzaffar = {
        isNormalUser = true;
        description = "Muzaffar Anasbekov";
        initialPassword = "2ReTpN1XG2VOR4aR";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHDSH+E/7791S2x2QF3WsQU1nnr7WNLyK1BubDmOeib muzaffar.gaming7@gmail.com"
        ];
        extraGroups = [ "networkmanager" "wheel" "docker" "admins" ];
      };
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs outputs; };
      users = {
        # Import your home-manager configuration
        muzaffar = import ../../../home/muzaffar.nix;
      };
    };
  };
}
