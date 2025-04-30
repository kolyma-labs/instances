{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "master";
    zones = [
      # Personal Space
      "orzklv.uz"
      "kolyma.uz"
      "gulag.uz"
      "khakimovs.uz"

      # Projects
      "slave.uz"
      "foss.uz"
      "floss.uz"
      "ecma.uz"
      "nyan.uz"
      "gopher.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "xinux.uz"
      "haskell.uz"
      "sabine.uz"
      "uzbek.net.uz"
      "devops-journey.uz"
      "trashiston.uz"
      "niggerlicious.uz"
    ];
    extra = ''
      key "ns3-updater" {
        algorithm hmac-sha256;
        secret "g4GjyW4IgOlx7vH6tTefows+o1echLGBTeYS+KTmZrE=";
      };

      zone "tarmoqchi.uz" {
        type master;
        file "/var/dns/tarmoqchi.uz.zone";
        allow-update { key "ns3-updater"; };
        allow-query { any; };
      };
    '';
  };
}
