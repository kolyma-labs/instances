{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid"];
  boot.initrd.kernelModules = ["nvme"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  boot.bios = {
    enable = true;
    raided = true;
    mirrors = ["/dev/nvme0n1"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0ba4c2c9-275b-42a0-92e1-74da751ea471";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FF65-BE3D";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/3ad38ead-cb6a-4e4c-9b5d-acb1fc67e444";}
  ];

  network = {
    enable = true;

    ipv4 = {
      enable = true;
      address = "65.109.61.35";
    };

    ipv6 = {
      enable = true;
      address = "2a01:4f9:5a:5110::";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
