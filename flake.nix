{
  #     _   ___         ______            ____
  #    / | / (_)  __   / ____/___  ____  / __/____
  #   /  |/ / / |/_/  / /   / __ \/ __ \/ /_/ ___/
  #  / /|  / />  <   / /___/ /_/ / / / / __(__  )
  # /_/ |_/_/_/|_|   \____/\____/_/ /_/_/ /____/
  description = "Kolyma's server configs";

  # Extra nix configurations to inject to flake scheme
  # nixConfig = {
  #   experimental-features = ["nix-command" "flakes" "pipe-operators"];
  # };

  # inputs are other flakes you use within your own flake, dependencies
  # for your flake, etc.
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/home.nix'.

    # Disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utils for eachSystem
    flake-utils.url = "github:numtide/flake-utils";

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
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
      inputs = {
        nixpkgs-25_05.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    # Reworked mastodon
    mastodon-backport.url = "github:teutat3s/nixpkgs/mastodon-4.4";

    # Main homepage website
    gate.url = "github:kolyma-labs/gate";

    # Khakimov's website
    khakimovs.url = "github:khakimovs/website";

    # Xinux Bot from Xinux Community
    xinux.url = "github:xinux-org/telegram";

    # Rustina from Rust Uzbekistan
    rustina.url = "github:rust-lang-uz/telegram";

    # Minecraft server
    minecraft.url = "github:Infinidoge/nix-minecraft";

    # Floss Uzbekistan website
    floss-website.url = "github:floss-uz/website";

    # DevOps Journey website
    devops-journey.url = "github:devops-journey-uz/devops-journey";

    # Tarmoqchi HTTP tunneling
    tarmoqchi.url = "github:floss-uz-community/tarmoqchi";

    # Social website of uzinfocom
    uzinfocom-website.url = "github:uzinfocom-org/website";

    # Social website of uzinfocom
    uzinfocom-taggis.url = "github:uzinfocom-org/taggis";

    # Efael website
    efael-website.url = "github:efael/website";
  };

  # In this context, outputs are mostly about getting nixpkgs what it
  # needs since it will be the one using the flake
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    ...
  } @ inputs: let
    # Self instance pointer
    outputs = self;
  in
    # Attributes for each system
    flake-utils.lib.eachDefaultSystem (
      system: let
        # Packages for the current <arch>
        pkgs = nixpkgs.legacyPackages.${system};

        # Checks hook for passing to devShell
        inherit (self.checks.${system}) pre-commit-check;
      in
        # Nixpkgs packages for the current system
        {
          # Checks for hooks
          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                #flake-checker.enable = true;
                # statix.enable = true;
                alejandra.enable = true;
              };
            };
          };

          # Formatter for your nix files, available through 'nix fmt'
          # Other options beside 'alejandra' include 'nixpkgs-fmt'
          formatter = pkgs.alejandra;

          # Development shells
          devShells.default = import ./shell.nix {inherit pkgs pre-commit-check;};
        }
    )
    # and ...
    //
    # Attribute from static evaluation
    {
      # Nixpkgs and internal helpful functions
      lib = nixpkgs.lib // import ./lib {inherit (nixpkgs) lib;};

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays {inherit inputs;};

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
