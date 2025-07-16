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
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1+nzkkkNn9TAS76Ld497ZReJP0OPj+jBklf6u2L+3kiHz9By4R8VXJBM9wzy1Eq2rgszR5up3uUMZ0sV02/42ZDrvuiAqGdGO3cRLdOq8W9qrZte7XUwOENwM1KeDJvcRY8nZV2GPH9mh635Finbs9KibCLk5ReIjUnHdfrwnGSI9yeHab94B/1EaeBb2W2Vd44rpF7ojSaCL2rG7zxSHjtXkhalcbtFOQS8cyzAIv/obq7FDnuvHhA4CmsDxG89wboeRGA626dQKej39nVkJcz5fypqkShLD5W8/5iR8axbbtcro9L6EoDo8XSfl0B8N7OJk/VV0BX7EeUHQCq6mtvhQdxVynyWqDDDQY4UfpkGUxn5itGZOWTjolYzJWnjpE7wUCn8g2gyPUQmpyNLdnTLSGcgbRbp2J5JYZN5L6lmsnqI9QXH2s4tU1MU038HEdPZpZgpEQNtrM7MmMju7icfX2LXTfPpcXHfaYX+p7B3/ICjQW+b3lF989C8l39dRUzU5yGXHFTGpHVIYFEuwWdQVdZeK2txgIwmMoC4fjmo7gacaqxIL1nlIBcYTlZIRKiXr/XmstwCKbLNnkyuivNJMc54FxEGQneGGi+O5AQWiV6tmhgXIb0tzD9J2bhD7Ma8vDgk38W7Tv6DjcQWLaCTQBED6wDFUZOnHyAt+lw== CryPTON's SSH Keygen"
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
