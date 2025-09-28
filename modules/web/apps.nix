{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.kolyma.www;

  bnest = mod: lib.strings.splitString "." mod;

  nest = keys: value:
    if keys == []
    then value
    else {${builtins.head keys} = nest (builtins.tail keys) value;};

  # Generate an app configuration
  generate = app: {...}: let
    nested =
      "services.${app.option}"
      |> bnest
      |> nest;
  in {
    imports = [
      inputs.${app.inputs}.nixosModules.${app.module}
    ];

    config = {
      ${nested} = {
        enable = true;

        proxy = {
          enable = true;
          inherit (app) domain;
        };
      };
    };
  };

  convert = map generate cfg.apps;
in {
  imports = lib.mkIf cfg.enable convert;

  options.kolyma.www.apps = with lib.types; with lib.kotypes; listOf apps;
}
