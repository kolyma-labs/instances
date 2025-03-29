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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/home.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # Orzklv's Nix configuration
    orzklv = {
      url = "github:orzklv/nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Orzklv's packages repository
    orzklv-pkgs = {
      url = "github:orzklv/pkgs/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
  };

  # In this context, outputs are mostly about getting home-manager what it
  # needs since it will be the one using the flake
  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    orzklv,
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
      in
        # Nixpkgs packages for the current system
        {
          # Development shells
          devShells.default = import ./shell.nix {inherit pkgs;};
        }
    )
    # and ...
    //
    # Attribute from static evaluation
    {
      # Nixpkgs and Home-Manager helpful functions
      lib = nixpkgs.lib // home-manager.lib // orzklv.lib;

      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      inherit (orzklv) formatter;

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays {inherit inputs;};

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = self.lib.config.mapSystem {
        inherit inputs outputs;
        opath = ./.;
        list = [
          "Kolyma-1"
          "Kolyma-2"
        ];
      };
    };
}
