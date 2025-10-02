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

      password = lib.options.mkOption {
        default = null;
        example = "someRandomInitialPassword";
        description = "An initial password to set for KVM uses.";
        type = with lib.types; nullOr str;
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

  runner = {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        example = "Important-Runner";
        description = "Name for the runnner used in service and registration.";
      };
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Whether to enable THIS runnner service.";
      };
      url = lib.mkOption {
        type = lib.types.str;
        example = "https://git.example.com/some-org";
        description = "Registration url given by git provider.";
      };
      token = lib.mkOption {
        type = lib.types.path;
        example = "/run/secrets/...";
        description = "Path to a secret file containing registration token.";
      };
      type = lib.mkOption {
        type = lib.types.enum ["forgejo" "github"];
        example = "forgejo";
        description = "Type of git provider runner is going to serve for.";
      };
    };
  };

  cdn = {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        description = "Which path should be served publicly.";
      };

      mode = lib.mkOption {
        type = lib.types.enum ["static" "browse"];
        default = "static";
        description = "Should nginx show file listing.";
      };

      alias = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of extra aliases to associate.";
      };

      extra = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Something extra to pass to nginx location config.";
      };
    };
  };
in {inherit users groups runner cdn;}
