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

  apps = {
    options = {
      inputs = lib.options.mkOption {
        description = "Name of input reference to import module from.";
        example = "example";
        type = lib.types.str;
      };

      module = lib.options.mkOption {
        description = "Modules name to be imported to expose deployment modules.";
        example = "example";
        type = lib.types.str;
      };

      option = lib.options.mkOption {
        description = "Option endpoint to set configurations.";
        example = "services.example";
        type = lib.types.str;
      };

      domain = lib.options.mkOption {
        description = "Domain to proxy the app behind.";
        example = "example.com";
        type = lib.types.str;
      };

      secrets = lib.options.mkOption {
        description = "Secrets to pass to the app.";
        example = {
          some = "/run/secrets/some";
          thing = "/run/secrets/thing";
        };
        type = lib.typeOf.attrs;
      };
    };
  };
in {inherit users groups apps;}
