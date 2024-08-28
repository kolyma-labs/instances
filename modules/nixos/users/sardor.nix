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
      sardor = {
        isNormalUser = true;
        description = "Sardor Qodirjonov";
        initialPassword = "F1st1ng15300Buck$!?";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATIYPqUdcP64tufjGii7LNncg5N2AzX7fj4JH3Vtdq2 mhw0@yahoo.com"
        ];
        extraGroups = [ "docker" "admins" ];
      };
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs outputs; };
      users = {
        # Import your home-manager configuration
        sardor = import ../../../home/sardor.nix;
      };
    };
  };
}
