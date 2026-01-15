# This file defines overlays
{ inputs, ... }:
{
  # Make input added packages accesible via pkgs
  additional-packages = final: prev: rec {
    # By flake
    personal = {
      gate = inputs.gate.packages."${final.stdenv.hostPlatform.system}".default;
      fluffy-efael = inputs.efael-messenger.packages.${final.stdenv.hostPlatform.system}.web;
    };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: _: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Use latest unstable version of matrix & mastodon
    inherit (final.unstable) matrix-synapse mastodon;

    # Use latest version of mas
    matrix-authentication-server = final.unstable.matrix-authentication-service.override;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
