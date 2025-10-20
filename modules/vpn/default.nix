{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.vpn;
in {
  imports =
    builtins.readDir ./.
    |> builtins.attrNames
    |> builtins.filter (m: m != "default.nix")
    |> builtins.filter (m: m != "readme.md")
    |> builtins.map (m: ./. + "/${m}");

  options = {
    kolyma.vpn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    kolyma = let
      domain = "vpn.kolyma.uz";
    in {
      wireguard = {
        enable = true;
        port = 6666;
      };

      openvpn = {
        enable = true;
        port = 6969;
        inherit domain;
      };
    };
  };
}
