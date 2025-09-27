{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              size = "2G";
              type = "EF00";
              priority = 2;
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            SWAP = {
              size = "130G";
              content = {
                type = "mdraid";
                name = "swap";
              };
            };
            ROOT = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
      nvme1n1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            SWAP = {
              size = "130G";
              content = {
                type = "mdraid";
                name = "swap";
              };
            };
            ROOT = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
    };
    mdadm = {
      root = {
        type = "mdadm";
        level = 1;
        content = {
          type = "gpt";
          partitions.primary = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
      boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };
      swap = {
        type = "mdadm";
        level = 1;
        content = {
          type = "swap";
        };
      };
    };
  };
}
