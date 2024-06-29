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

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.

  # Simplified
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

  # Documented way
  networking = {
    useDHCP = false;

    interfaces = {
      eth0 = {
        useDHCP = true;

        ipv4.addresses = [
          {
            address = "65.109.61.35";
            prefixLength = 24;
          }
        ];

        ipv6.addresses = [
          {
            address = "2a01:4f9:5a:5110::";
            prefixLength = 64;
          }
        ];
      };
    };

    # If you want to configure the default gateway
    defaultGateway = {
      address = "65.109.61.1"; # Replace with your actual gateway for IPv4
      interface = "eth0"; # Replace with your actual interface
    };

    defaultGateway6 = {
      address = "fe80::1"; # Replace with your actual gateway for IPv6
      interface = "eth0"; # Replace with your actual interface
    };

    # Optional DNS configuration
    nameservers = ["8.8.8.8" "8.8.4.4"]; # Replace with your desired DNS servers
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
