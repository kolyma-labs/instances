{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  # Matrix related domains
  domains = rec {
    main = "efael.uz";
    call = "call.${main}";
    server = "matrix.${main}";
    livekit = "livekit.${main}";
    livekit-jwt = "livekit-jwt.${main}";
  };
in {
  imports = [
    # Parts of this configuration
    (import ./www.nix {inherit inputs;})
    (import ./call.nix {inherit config domains;})
    (import ./proxy {inherit lib domains pkgs config;})
  ];
}
