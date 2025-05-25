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

    # mastodon-custom = prev.mastodon.override {
    #   patches = [
    #     ./char-limit.patch
    #   ];
    # };

    matrix-authentication-server = prev.matrix-authentication-service.override {
      postPatch = ''
        substituteInPlace crates/config/src/sections/http.rs \
          --replace ./frontend/dist/    "$out/share/$pname/assets/"
        substituteInPlace crates/config/src/sections/templates.rs \
          --replace ./share/templates/    "$out/share/$pname/templates/" \
          --replace ./share/translations/    "$out/share/$pname/translations/" \
          --replace ./share/manifest.json "$out/share/$pname/assets/manifest.json"
        substituteInPlace crates/config/src/sections/policy.rs \
          --replace ./share/policy.wasm "$out/share/$pname/policy.wasm"
      '';
    };
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
