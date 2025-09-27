{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.users;

  users = {
    options = {
      username = lib.options.mkOption {
        default = "";
        example = "example";
        description = "Username for user's .";
        type = lib.types.str;
      };

      description = lib.options.mkOption {
        default = "";
        example = "example";
        description = "More detailed name or username for finding.";
        type = lib.types.str;
      };

      keys = lib.options.mkOption {
        default = null;
        example = [];
        description = "More detailed name or username for finding.";
        type = with lib.types; nullOr listOf singleLineStr;
      };

      keysUrl = lib.options.mkOption {
        default = null;
        example = "example";
        description = "More detailed name or username for finding.";
        type = with lib.types; nullOr str;
      };

      sha256 = lib.options.mkOption {
        default = null;
        example = "example";
        description = "More detailed name or username for finding.";
        type = with lib.types; nullOr str;
      };
    };
  };

  groups = {
    options = {
      members = lib.options.mkOption {
        default = [];
        example = [lib.labors.orzklv];
        description = "Members of the team";
        type = with lib.types; listOf (submodule users);
      };

      scope = lib.options.mkOption {
        default = "";
        example = "example";
        description = "More detailed name or username for finding.";
        type = lib.types.str;
      };
    };
  };
in {
  options = {
    kolyma.users = {
      teams = lib.options.mkOption {
        default = [lib.camps.owners];
        example = [lib.camps.prisioners];
        description = "Team of users to be added to the system.";
        type = with lib.types; listOf (submodule groups);
      };

      users = lib.options.mkOption {
        default = [];
        example = [lib.labors.orzklv];
        description = "Users to be added to the system.";
        type = with lib.types; listOf (submodule users);
      };
    };
  };

  config = let
    teams =
      lib.flatten (map (team: team.members) cfg.teams);

    all =
      cfg.users ++ teams;

    merge =
      lib.uniqueBy (u: u.username) all;
  in
    lib.kolyma.users.mkUsers merge;

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
