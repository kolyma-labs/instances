{
  lib,
  config,
  ...
}:
let
  cfg = config.kolyma.extra;
in
{
  imports =
    builtins.readDir ./.
    |> builtins.attrNames
    |> builtins.filter (m: m != "default.nix")
    |> builtins.filter (m: m != "readme.md")
    |> builtins.map (m: ./. + "/${m}");

  options = {
    kolyma.extra = {
      enable = lib.options.mkOption {
        default = true;
        example = false;
        description = "Whether to add some extra configurations to the system.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    kolyma = {
      # Documentations
      docs.enable = true;

      # Data Maintainance
      data.enable = true;

      # Update Management
      update.enable = true;
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [ orzklv ];
  };
}
