{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    # Disko partitioning
    inputs.disko.nixosModules.disko
    ./disk-configuration.nix

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.bios = {
    enable = true;
    uefi = true;
    raided = true;
    mirrors = [
      "/dev/nvme0n1"
      "/dev/nvme1n1"
    ];
  };

  network = {
    enable = true;

    ipv4 = {
      enable = true;
      address = "65.109.74.214";
    };

    ipv6 = {
      enable = true;
      address = "2a01:4f9:3071:31ce::";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
