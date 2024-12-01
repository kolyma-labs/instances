{ outputs, ... }:
{
  imports = [ outputs.nixosModules.caddy ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns5.kolyma.uz" ];
    hosts =
      {
      };
  };
}
