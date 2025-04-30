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
      zone "tarmoqchi.uz" {
        type master;
        file "/var/dns/tarmoqchi.uz.zone";
        allow-update { 116.202.247.9; };
        allow-query { any; };
      };
    '';
  };
}
