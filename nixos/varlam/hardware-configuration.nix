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
      kernelModules = [
        "nvme"
        "kvm-intel"
      ];
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
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
      ipv4 = "37.27.67.190";
      ipv6 = "2a01:4f9:3081:3518::2";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
