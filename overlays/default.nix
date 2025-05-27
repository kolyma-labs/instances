# This file defines overlays
{inputs, ...}: {
  # Make input added packages accesible via pkgs
  personal-packages = final: _prev: rec {
    personal = {
      gate = inputs.gate.packages."${final.system}".default;
      khakimovs = inputs.khakimovs.packages."${final.system}".default;
    };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Patched mastodon with custom char limit
    # mastodon-custom = prev.mastodon.override {
    #   patches = [
    #     ./char-limit.patch
    #   ];
    # };

    # Use latest unstable version of matrix
    matrix-synapse = final.unstable.matrix-synapse;

    # Use latest version of mas
    matrix-authentication-server = final.unstable.matrix-authentication-service.override;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
