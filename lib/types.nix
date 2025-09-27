{lib}: let
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
in {inherit users groups;}
