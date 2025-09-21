{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "master";

    slaves = [
      "65.109.74.214"
    ];

    zones = [
      # Personal Space
      "orzklv.uz"
      "kolyma.uz"
      "gulag.uz"
      "khakimovs.uz"

      # Personal Projects
      "foss.uz"
      "ecma.uz"
      "nyan.uz"
      "slave.uz"
      "xinux.uz"
      "floss.uz"
      "bleur.net"
      "uzberk.uz"
      "gopher.uz"
      "sabine.uz"
      "haskell.uz"
      "php.org.uz"
      "uzbek.net.uz"
      "tarmoqchi.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "trashiston.uz"
      "nix-darwin.uz"
      "niggerlicious.uz"
      "devops-journey.uz"

      # Goofy Ahh Zone
      "efael.uz"
      "efael.net"
      "uchar.uz"

      # Dangarus Zone
      "oss.uzinfocom.uz"
      "link.uzinfocom.uz"
    ];

    extra = ''
      key "acme-key" {
        algorithm hmac-sha512;
        secret "Q06/9d+NXw6eE5Z0S4Envkh4RKZZb96aM7V8M0SEqppguaeVNmO85qcCG80MGGWiqGO+qsy2bL9LkMNUpKGVgw==";
      };
    '';
  };
}
