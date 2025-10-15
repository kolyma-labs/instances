{
  lib,
  config,
  options,
  ...
}: let
  cfg = config.kolyma.vpn;
  opts = options.kolyma.vpn-option;
in {
  imports = [
    # OpenVPN module implementation
    ./openvpn.nix

    # Wireguard module implementatino
    ./wireguard.nix
  ];

  options = {
    kolyma.vpn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the containers service.";
      };

      software = lib.mkOption {
        type = lib.types.enum [
          "openvpn"
          "wireguard"
        ];
        default = "wireguard";
        description = "Enable the containers service.";
      };

      settings =
        if cfg.software == "openvpn"
        then opts.openvpn
        else if cfg.software == "wireguard"
        then opts.wireguard
        else
          lib.mkOption {
            type = lib.types.anything;
            description = "Chosen software is quite unknown for the module.";
          };
    };
  };

  config = lib.mkIf cfg.enable {
    kolyma.vpn-option.${cfg.software} =
      {inherit (cfg) enable;} // cfg.settings;
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
