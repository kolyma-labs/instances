{
  inputs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-configuration.nix

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
    boot = {
      uefi = true;
      raided = true;
      mirrors = [
        "/dev/nvme0n1"
        "/dev/nvme1n1"
      ];
    };

    network = {
      ipv4 = "65.109.103.11";
      ipv6 = "2a01:4f9:3080:2829::2";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
