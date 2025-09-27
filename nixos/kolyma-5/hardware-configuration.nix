{
  inputs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    # Disko partitioning
    inputs.disko.nixosModules.disko
    ./disk-configuration.nix

    # Not available hardware modules
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      kernelModules = ["nvme"];
      availableKernelModules = [
        "ahci"
        "nvme"
        "usbhid"
        "xhci_pci_renesas"
      ];
    };
  };

  kolyma = {
    bios = {
      uefi = true;
      raided = true;
      mirrors = [
        "/dev/nvme0n1"
        "/dev/nvme1n1"
      ];
    };

    network = {
      ipv4 = "167.235.96.40";
      ipv6 = "2a01:4f8:2190:2914::2";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
