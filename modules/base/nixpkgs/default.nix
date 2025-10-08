{
  outputs,
  lib,
  config,
  inputs,
  options,
  ...
}: let
  cfg = config.kolyma.nixpkgs;
in {
  options = {
    kolyma.nixpkgs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable kolyma nixpkgs configurations.";
      };

      inherit (options.nixpkgs) overlays;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      # You can add overlays here
      overlays =
        [
          # Add overlays your own flake exports (from overlays and pkgs dir):
          outputs.overlays.modifications
          outputs.overlays.unstable-packages
          outputs.overlays.additional-packages

          # Repo overlays
          # TODO: move to mc module
          inputs.minecraft.overlay

          # Or define it inline, for example:
          # (final: prev: {
          #   hi = final.hello.overrideAttrs (oldAttrs: {
          #     patches = [ ./change-hello-to-hi.patch ];
          #   });
          # })
        ]
        ++ cfg.overlays;

      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
      };
    };

    nix = {
      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes pipe-operators";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
        # Trusted users for secret-key
        trusted-users = builtins.map (o: o.username) lib.camps.owners.members;
      };
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
