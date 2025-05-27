{
  lib,
  pkgs,
  config,
  outputs,
  ...
}: let
  # Matrix related domains
  domains = rec {
    main = "efael.net";
    client = "chat.${main}";
    server = "matrix.${main}";
    auth = "auth.${main}";
    realm = "turn.${main}";
  };

  # Various temporary keys
  keys = {
    realmkey = "the most niggerlicious thing is to use javascript and python :(";
  };
in {
  imports = [
    # Module by @...
    outputs.nixosModules.mas

    # Parts of this configuration
    (import ./proxy {inherit lib domains pkgs;})
    (import ./auth.nix {inherit config domains;})
    (import ./turn.nix {inherit lib config domains keys;})
    (import ./server.nix {inherit lib config domains keys;})
  ];
}
