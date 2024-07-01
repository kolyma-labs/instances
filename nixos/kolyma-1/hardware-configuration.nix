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
    mirrors = ["/dev/nvme0n1" "/dev/nvme1n1"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/484dd5fe-7269-4f51-b40a-12615fdc2dc8";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5979-8294";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/e41e140f-53f3-4663-b6e4-db64dc02c2f2";}
  ];


  network = {
    enable = true;
    
    ipv4 = {
      enable = true;
      address = "5.9.66.12";
    };

    ipv6 = {
      enable = true;
      address = "2a01:4f8:161:714c::";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
