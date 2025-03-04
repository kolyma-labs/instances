{
  config,
  inputs,
  ...
}: let
  key = "${config.users.users.sakhib.home}/.config/sops/age/keys.txt";
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = key;
    };
  };
}
