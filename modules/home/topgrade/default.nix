{pkgs, ...}: {
  config = {
    programs.topgrade = {
      enable = true;
      settings = {
        misc = {
          disable = [
            "bun"
            "node"
            "pnpm"
            "yarn"
            "cargo"
            "vscode"
            "home_manager"
          ];
          no_retry = true;
          assume_yes = true;
          no_self_update = true;
        };
        commands = {};
        linux = {
          nix_arguments = "--flake github:kolyma-labs/instances";
          home_manager_arguments = ["--flake" "github:kolyma-labs/instances"];
        };
      };
    };
  };
}
