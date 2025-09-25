{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "slave";

    masters = [
      "167.235.96.40"
      "2a01:4f8:2190:2914::"
    ];
  };
}
