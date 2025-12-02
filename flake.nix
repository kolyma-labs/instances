{
  # ====================================================================
  # oooo    oooo           oooo
  # `888   .8P'            `888
  #  888  d8'     .ooooo.   888  oooo    ooo ooo. .oo.  .oo.    .oooo.
  #  88888[      d88' `88b  888   `88.  .8'  `888P"Y88bP"Y88b  `P  )88b
  #  888`88b.    888   888  888    `88..8'    888   888   888   .oP"888
  #  888  `88b.  888   888  888     `888'     888   888   888  d8(  888
  # o888o  o888o `Y8bod8P' o888o     .8'     o888o o888o o888o `Y888""8o
  #                              .o..P'
  #                              `Y8P'
  # ====================================================================
  description = "Global Kolyma's Server Configurations owned by Orzklv";
  # ====================================================================

  # Extra nix configurations to inject to flake scheme
  # => use if something doesn't work out of box or when despaired...
  nixConfig = {
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    extra-substituters = ["https://cache.xinux.uz/"];
    extra-trusted-public-keys = ["cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="];
  };

  # inputs are other flakes you use within your own flake, dependencies
  # for your flake, etc.
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/home.nix'.

    # Disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre commit hooks for git
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mail Server
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Reworked mastodon
    mastodon-backport.url = "github:teutat3s/nixpkgs/mastodon-4.4";

    # Main homepage website
    gate.url = "github:kolyma-labs/gate";

    # Khakimov's website
    khakimovs-website.url = "github:khakimovs/website";

    # Xinux Bot from Xinux Community
    xinuxmgr-bot.url = "github:xinux-org/telegram";

    # Rustina from Rust Uzbekistan
    rustina-bot.url = "github:rust-lang-uz/telegram";

    # Minecraft server
    minecraft.url = "github:Infinidoge/nix-minecraft";

    # Floss Uzbekistan website
    floss-website.url = "github:floss-uz/website";

    # Uzbek Localization project website
    uzbek-net-website.url = "github:uzbek-net/website";

    # DevOps Uzbekistan guide book
    devops-book.url = "github:devopsuzb/book";

    # Tarmoqchi HTTP tunneling
    tarmoqchi.url = "github:floss-uz-community/tarmoqchi";

    # Social website of uzinfocom
    uzinfocom-website.url = "github:uzinfocom-org/website";

    # Social website of uzinfocom
    uzinfocom-taggis.url = "github:uzinfocom-org/taggis";

    # Efael website
    efael-website.url = "github:efael/website";

    # Efael messenger
    efael-messenger.url = "github:efael/fluffy/efael/app/v2.2.0";
  };

  # In this context, outputs are mostly about getting nixpkgs what it
  # needs since it will be the one using the flake
  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    ...
  } @ inputs: let
    # Self instance pointer
    inherit (self) outputs;

    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Nixpkgs and internal helpful functions
    lib = nixpkgs.lib // import ./lib {inherit (nixpkgs) lib;};

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Checks for hooks
    checks = forAllSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          statix = let
            pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
          in {
            enable = true;
            package =
              pkgs.statix.overrideAttrs
              (_o: rec {
                src = pkgs.fetchFromGitHub {
                  owner = "oppiliappan";
                  repo = "statix";
                  rev = "43681f0da4bf1cc6ecd487ef0a5c6ad72e3397c7";
                  hash = "sha256-LXvbkO/H+xscQsyHIo/QbNPw2EKqheuNjphdLfIZUv4=";
                };

                cargoDeps = pkgs.rustPlatform.importCargoLock {
                  lockFile = src + "/Cargo.lock";
                  allowBuiltinFetchGit = true;
                };
              });
          };
          alejandra.enable = true;
          flake-checker.enable = true;
        };
      };
    });

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Development shells
    devShells = forAllSystems (system: {
      default = import ./shell.nix {
        inherit (self.checks.${system}) pre-commit-check;
        pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
      };
    });

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules =
      builtins.readDir ./modules
      |> builtins.attrNames
      |> map (x: {
        name = x;
        value = import (./modules + "/${x}");
      })
      |> builtins.listToAttrs;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = self.lib.instances.mapSystem {
      list =
        builtins.readDir ./hosts
        |> builtins.attrNames
        |> map (h: self.lib.kstrings.capitalize h);
      inherit inputs outputs;
    };
  };
}
