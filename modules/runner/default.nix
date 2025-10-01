{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.kolyma.runners;

  mkGitHub = param: {
    github-runners = {
      "Kolyma-${param.name}" = {
        inherit (param) enable url;
        inherit (cfg) user group;
        tokenFile = param.token;
        replace = true;
        extraLabels = [param.name];
        package = pkgs.unstable.github-runner;
        serviceOverrides = {
          ProtectSystem = "full";
          ReadWritePaths = "/srv";
          PrivateMounts = false;
          UMask = 22;
        };
      };
    };
  };

  mkForgejo = param: {
    gitea-actions-runner = {
      package = lib.mkDefault pkgs.unstable.forgejo-actions-runner;
      instances."Kolyma-${param.name}" = {
        inherit (param) enable name url;
        tokenFile = param.token;
        labels = ["native:host"];
      };
    };
  };

  patchForgejo = param: {
    "gitea-runner-Kolyma-${param.name}".serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce cfg.user;
      Group = lib.mkForce cfg.group;
    };
  };
in {
  options = {
    kolyma.runners = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable git hosting provider runners";
      };

      instances = lib.mkOption {
        type = with lib.types; listOf (submodule lib.kotypes.runner);
        default = [];
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "runner";
        example = "git-runner";
        description = "Enable git hosting provider runners.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "runner";
        example = "git-runner";
        description = "Enable git hosting provider runners.";
      };
    };
  };

  config = let
    extra = [
      {
        gitea-actions-runner = {
          package = pkgs.unstable.forgejo-runner;
        };
      }
    ];

    result = lib.lists.forEach cfg.instances (
      param: (lib.rmatch.match param [
        [{type = "github";} (mkGitHub param)]
        [{type = "forgejo";} (mkForgejo param)]
      ])
    );
  in
    lib.mkIf cfg.enable {
      users.users.${cfg.user} = {
        description = "Git Runner user";
        isNormalUser = true;
        createHome = false;
        extraGroups = ["admins"];
        group = cfg.group;
      };

      users.groups.${cfg.group} = {};

      services =
        lib.mkMerge (result ++ extra);

      systemd.services =
        cfg.instances
        |> builtins.filter (i: i.type == "forgejo")
        |> map patchForgejo
        |> lib.mkMerge;
    };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
