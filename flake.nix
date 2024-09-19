{
  #     _   ___         ______            ____
  #    / | / (_)  __   / ____/___  ____  / __/____
  #   /  |/ / / |/_/  / /   / __ \/ __ \/ /_/ ___/
  #  / /|  / />  <   / /___/ /_/ / / / / __(__  )
  # /_/ |_/_/_/|_|   \____/\____/_/ /_/_/ /____/
  description = "Kolyma's server configs";

  # inputs are other flakes you use within your own flake, dependencies
  # for your flake, etc.
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/home.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utils for eachSystem
    flake-utils.url = "github:numtide/flake-utils";

    # Main homepage website
    gate.url = "github:kolyma-labs/gate";
  };

  # In this context, outputs are mostly about getting home-manager what it
  # needs since it will be the one using the flake
  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , flake-utils
    , gate
    , ...
    } @ inputs:
    let
      # Self instance pointer
      outputs = self;

      afes = flake-utils.lib.eachDefaultSystem
        (system:
          let
            # Packages for the current <arch>
            pkgs = nixpkgs.legacyPackages.${system};
          in
          # Nixpkgs packages for the current system
          {
            # Your custom packages
            # Acessible through 'nix build', 'nix shell', etc
            packages = import ./pkgs {
              inherit pkgs;
            };

            # Formatter for your nix files, available through 'nix fmt'
            # Other options beside 'alejandra' include 'nixpkgs-fmt'
            formatter = pkgs.nixpkgs-fmt;

            # Development shells
            devShells.default = import ./shell.nix { inherit pkgs; };
          });

      afse = {
        # Nixpkgs and Home-Manager helpful functions
        lib = nixpkgs.lib // home-manager.lib;

        # Your custom packages and modifications, exported as overlays
        overlays = import ./overlays { inherit inputs; };

        # Reusable nixos modules you might want to export
        # These are usually stuff you would upstream into nixpkgs
        nixosModules = import ./modules/nixos;

        # Reusable home-manager modules you might want to export
        # These are usually stuff you would upstream into home-manager
        homeManagerModules = import ./modules/home;

        # Reusable server modules you might want to export
        # These are usually stuff you would upstream services to global
        serverModules = import ./modules/server;

        # NixOS configuration entrypoint
        # Available through 'nixos-rebuild --flake .#your-hostname'
        nixosConfigurations = {
          "Kolyma-1" = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              # > Our main nixos configuration file <
              ./nixos/kolyma-1/configuration.nix
            ];
          };
          "Kolyma-2" = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              # > Our main nixos configuration file <
              ./nixos/kolyma-2/configuration.nix
            ];
          };
          "Kolyma-3" = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              # > Our main nixos configuration file <
              ./nixos/kolyma-3/configuration.nix
            ];
          };
          "Kolyma-4" = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              # > Our main nixos configuration file <
              ./nixos/kolyma-4/configuration.nix
            ];
          };
        };

      };
    in
    # Merging all final results
    afse // afes;
}
