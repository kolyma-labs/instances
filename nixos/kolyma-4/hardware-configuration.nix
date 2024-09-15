{ config
, lib
, pkgs
, modulesPath
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ "nvme" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.bios = {
    enable = true;
    uefi = true;
    raided = true;
    mirrors = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/76f237de-5eb6-4241-894e-d024a29685c8";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/852A-FFFC";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/82953896-b081-4cc7-ad7b-c82c12a076ef"; }];

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
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
