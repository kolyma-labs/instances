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
    gate = {
      url = "github:kolyma-labs/gate";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Khakimov's website
    khakimovs = {
      url = "github:khakimovs/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Xinux Community
    xinux = {
      url = "github:xinux-org/telegram";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Orzklv's Nix configuration
    orzklv = {
      url = "github:orzklv/nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # In this context, outputs are mostly about getting home-manager what it
  # needs since it will be the one using the flake
  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , flake-utils
    , orzklv
    , gate
    , khakimovs
    , xinux
    , ...
    } @ inputs:
    let
      # Self instance pointer
      outputs = self;
    in

    # Attributes for each system
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        # Packages for the current <arch>
        pkgs = nixpkgs.legacyPackages.${system};
      in
      # Nixpkgs packages for the current system
      {
        # Your custom packages
        # Acessible through 'nix build', 'nix shell', etc
        packages = import ./pkgs { inherit pkgs; };

        # Formatter for your nix files, available through 'nix fmt'
        # Other options beside 'alejandra' include 'nixpkgs-fmt'
        formatter = pkgs.nixpkgs-fmt;

        # Development shells
        devShells.default = import ./shell.nix { inherit pkgs; };
      })

    # and ...
    //

    # Attribute from static evaluation
    {
      # Nixpkgs and Home-Manager helpful functions
      lib = nixpkgs.lib // home-manager.lib // orzklv.lib;

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations =
        self.lib.config.mapSystem {
          inherit inputs outputs;
          opath = ./.;
          list = [ "Kolyma-1" "Kolyma-2" "Kolyma-3" "Kolyma-4" ];
        };
    };

}
