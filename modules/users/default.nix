{
  lib,
  config,
  ...
}:
let
  cfg = config.kolyma.accounts;

  sudoless = {
    # Don't ask for password
    security.sudo.wheelNeedsPassword = false;
  };

  generic =
    let
      teams = lib.flatten (map (team: team.members) cfg.teams);

      all = cfg.users ++ teams;

      merge = lib.unique all;
    in
    lib.users.mkUsers merge;
in
{
  options = {
    kolyma.accounts = {
      teams = lib.options.mkOption {
        default = [ lib.camps.owners ];
        example = [ lib.camps.prisioners ];
        description = "Team of users to be added to the system.";
        type = with lib.types; with lib.kotypes; listOf (submodule groups);
      };

      users = lib.options.mkOption {
        default = [ lib.labors.orzklv ];
        example = [ lib.labors.shakhzod ];
        description = "Users to be added to the system.";
        type = with lib.types; with lib.kotypes; listOf (submodule users);
      };
    };
  };

  config = lib.mkMerge [
    generic
    sudoless
  ];

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [ orzklv ];
  };
}
