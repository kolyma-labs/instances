{
  outputs,
  lib,
  config,
  inputs,
  options,
  ...
}:
let
  cfg = config.kolyma.nixpkgs;
in
{
  options = {
    kolyma.nixpkgs = {
      enable = lib.mkEnableOption "kolyma nixpkgs configurations";

      master = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Is this the server that hosts cache?";
      };

      builder = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Can this server host as a remote builder?";
      };

      inherit (options.nixpkgs) overlays;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf cfg.builder {
      builder = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$dsXOFHWCyplfRPiwsKu0l0$7YXPRLohyW8QXfyITPP6Sag/l7XH3i7TO4uGByPKBb2";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7cbsIgVqOYd59cCiDfC2rSE1mY3eNAJyP1lF1K6G4s I'ma rebuild those derivations fast as fuck boi"
        ];
      };
    };

    nixpkgs = {
      # You can add overlays here
      overlays = [
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
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      settings = lib.mkMerge [
        (lib.mkIf (!cfg.master) {
          substituters = [ "https://cache.xinux.uz/" ];
          trusted-public-keys = [
            "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
          ];
        })
        {
          # Enable flakes and new 'nix' command
          experimental-features = "nix-command flakes pipe-operators";
          # Deduplicate and optimize nix store
          auto-optimise-store = true;
          # Trusted users for secret-key
          trusted-users = (map (o: o.username) lib.camps.owners.members) ++ [ "builder" ];
          # Enable IDF for the love of god
          allow-import-from-derivation = true;
        }
      ];
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [ orzklv ];
  };
}
