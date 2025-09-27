{
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Manually types some extra spicy zsh config
  extra = builtins.readFile ./extra.zsh;

  # Find and set path to executables
  exec = pkg: lib.getExe pkg;
in {
  config = {
    # Installing zsh for system
    programs.zsh = {
      # Install zsh
      enable = true;

      # ZSH Completions
      enableCompletion = true;

      # ZSH Autosuggestions
      autosuggestions.enable = true;

      # Bash Completions
      enableBashCompletion = true;

      # ZSH Syntax Highlighting
      syntaxHighlighting.enable = true;

      # Extra manually typed configs
      promptInit = extra;

      shellAliases = with pkgs; {
        # General aliases
        ".." = "cd ..";
        "...." = "cd ../..";
        "celar" = "clear";
        ":q" = "exit";
        neofetch = "fastfetch";

        # Made with Rust
        top = exec btop;
        cat = exec bat;
        ls = exec eza;
        sl = exec eza;
        ps = exec procs;
        grep = exec ripgrep;
        search = exec ripgrep;
        look = exec fd;
        find = exec fd;
        ping = exec gping;
        time = exec hyperfine;

        # Development
        vi = exec helix;
        vim = exec helix;

        # Others (Developer)
        ports = "ss -lntu";
        speedtest = "curl -o /dev/null cachefly.cachefly.net/100mb.test";

        # Updating system
        update = "sudo nixos-rebuild switch --flake github:kolyma-labs/instances --option tarball-ttl 0 --show-trace";
      };
    };

    # Zoxide path integration
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Prettier terminal prompt
    programs.starship = {
      enable = true;
    };

    programs.direnv = {
      enable = true;
      silent = true;
      loadInNixShell = false;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    # All users default shell must be zsh
    users.defaultUserShell = pkgs.zsh;

    # System configurations
    environment = {
      shells = with pkgs; [zsh];
      pathsToLink = ["/share/zsh"];
      systemPackages = with pkgs; [inputs.home-manager.packages.${pkgs.system}.default];
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
