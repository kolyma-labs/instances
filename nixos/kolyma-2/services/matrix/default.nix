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
    main = "floss.uz";
    client = "chat.${main}";
    server = "matrix.${main}";
    auth = "auth.${main}";
    realm = "turn.${main}";
    mail = "mail.${main}";
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
    (import ./proxy {inherit lib domains pkgs;})
    (import ./auth.nix {inherit config domains;})
    (import ./turn.nix {inherit lib config domains keys;})
    (import ./server.nix {inherit lib config domains keys;})
  ];
}
