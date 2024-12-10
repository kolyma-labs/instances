{
  pkgs,
  outputs,
  lib,
  config,
  inputs,
  ...
}: {
  config = {
    nixpkgs = {
      # You can add overlays here
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        outputs.overlays.personal-packages

        # You can also add overlays exported from other flakes:
        # neovim-nightly-overlay.overlays.default

        # Repo overlays
        inputs.minecraft.overlay

        # Broken wasm-bindgen
        (final: prev: {
          stalwart-mail-wbf = final.unstable.stalwart-mail.overrideAttrs (old: {
            passthru.webadmin = final.unstable.stalwart-mail.webadmin.override {
              wasm-bindgen-cli = final.unstable.wasm-bindgen-cli.override {
                version = "0.2.93";
                hash = "sha256-DDdu5mM3gneraM85pAepBXWn3TMofarVR4NbjMdz3r0=";
                cargoHash = "sha256-birrg+XABBHHKJxfTKAMSlmTVYLmnmqMDfRnmG6g/YQ=";
              };
            };
          });
        })

        # Or define it inline, for example:
        # (final: prev: {
        #   hi = final.hello.overrideAttrs (oldAttrs: {
        #     patches = [ ./change-hello-to-hi.patch ];
        #   });
        # })
      ];
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
        allowUnsupportedSystem = true;
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
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
      };
    };
  };
}
