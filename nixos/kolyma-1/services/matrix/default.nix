{
  lib,
  pkgs,
  config,
  inputs,
  outputs,
  ...
}: let
  # Matrix related domains
  domains = rec {
    main = "efael.net";
    client = "chat.${main}";
    call = "call.${main}";
    server = "matrix.${main}";
    auth = "auth.${main}";
    realm = "turn.${main}";
    mail = "mail.${main}";
    livekit = "livekit.${main}";
    livekit-jwt = "livekit-jwt.${main}";
  };

  # Various temporary keys
  keys = {
    realmkey = "the most niggerlicious thing is to use javascript and python :(";
  };
in {
  imports = [
    # Module by @teutat3s
    outputs.nixosModules.mas

    # Parts of this configuration
    (import ./www.nix {inherit inputs;})
    (import ./call.nix {inherit config domains;})
    (import ./auth.nix {inherit config domains;})
    (import ./proxy {inherit lib domains pkgs config;})
    (import ./mail.nix {inherit inputs domains config;})
    (import ./turn.nix {inherit lib config domains keys;})
    (import ./server.nix {inherit lib config domains keys;})
  ];
}
