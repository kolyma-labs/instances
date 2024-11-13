{ pkgs
, inputs
, outputs
, lib
, config
, packages
, ...
}:
let
  username = "sabine";
in
{
  config = {
    users.users = {
      "${username}" = {
        isNormalUser = true;
        description = "Sabine";
        initialPassword = "F1st1ng15300Buck$!?";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbD3g0xhs7urX9egMlB2ArCmc0wOpTHqS585Xu78XaIL9nzST832CxJ8DNHhdl4Kgvr5GYbkEo9DR0Kv/sbfJTMuGDJB/8a++8hlBTWznFR5AgKxcMugQ7lb2PLBE41rUBR/DCFNYkn8EAnvSRTJe1MH2SEETUpPzRTrjJgq2Qgv5PH8aILCAIy9sE3CgrXBZ3PZrcwVAPxFsSVxWGDQPg26AJKgbsiZzrwkqqSsMe7yNONbOLENbP36FZHud4lkNNPEKD4mwGiP/ME/KU7R3JY0IIxqHo5zCP0ku1TixW/50hzrLZ6mUV+2/H3r1/818jxK/hOCYAzTKH1dMh7gVja32fkchBOYA1kOj3Yy96o55dIw87WnQwMRBacHJ/ptiy0xrF6NcspHMFrkzcj2xwrDF11KLFNdISPx5wK+ow3wXMt6XdI3b/8ZySr1JGncKH/KECoFGaQIFBjBgqw8R+2DsgSkv9oUJWBStrxKGHeZZhtjYFG4b+9hycLM1bOYsdtU2dEZFATmEF/tiZfbujqF57BuWUx6+r1rp4PDtzqHFYtfpLaexsuk+Wdn8J+jVC56IdzNBS1s/tmgGBd4LYclWuKyWCRXtQxoA0iebULpiIi/uq7xwiIgyhPDRMjOaMeKRgR5uM4QOJyjt642Jw1pnZyR4kooA1acWuyWkBBw== sabine@pop-os"
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
