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
          # TODO: "wireguard"
        ];
        default = "openvpn";
        description = "Enable the containers service.";
      };

      settings = opts.openvpn;
      # if cfg.type == "openvpn"
      # then opts.openvpn
      # else opts.wireguard;
    };
  };

  config = lib.mkIf cfg.enable {
    kolyma.vpn-option."${cfg.software}" = (
      {enable = true;} // cfg.settings
    );
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
