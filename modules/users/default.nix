{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.accounts;

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
        default = [];
        example = [];
        description = "More detailed name or username for finding.";
        type = with lib.types; listOf singleLineStr;
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

  sudoless = {
    # Don't ask for password
    security.sudo.wheelNeedsPassword = false;
  };

  generic = let
    teams =
      lib.flatten (map (team: team.members) cfg.teams);

    all =
      cfg.users ++ teams;

    merge =
      lib.unique all;
  in
    lib.users.mkUsers merge;
in {
  options = {
    kolyma.accounts = {
      teams = lib.options.mkOption {
        default = [lib.camps.owners];
        example = [lib.camps.prisioners];
        description = "Team of users to be added to the system.";
        type = with lib.types; listOf (submodule groups);
      };

      users = lib.options.mkOption {
        default = [lib.labors.orzklv];
        example = [lib.labors.shakhzod];
        description = "Users to be added to the system.";
        type = with lib.types; listOf (submodule users);
      };
    };
  };

  config = lib.mkMerge [generic sudoless];

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
