{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "master";

    slaves = [
      "65.109.74.214"
      "2a01:4f9:3071:31ce::"
    ];
  };
}
