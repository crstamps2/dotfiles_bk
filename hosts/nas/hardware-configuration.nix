# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-label/swap";}
  ];

  networking = {
    useDHCP = lib.mkDefault true; # Disable global DHCP
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    firewall.enable = false;
    firewall.allowPing = true;
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    netdevs = {
      "20-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
          # TODO: change this to the MAC address of the existing mellanox card that will actually be used when installed to the new case
          MACAddress = "3c:ec:ef:b5:bf:6f";
          Description = "br0 bridged interface for eno1";
        };
      };
      "30-vlk8s20" = {
        netdevConfig = {
          Name = "vlk8s20";
          Kind = "vlan";
          Description = "VLAN 20 (k8s nodes)";
        };
        vlanConfig = {
          Id = 20;
        };
      };
      "40-k8s20" = {
        netdevConfig = {
          Name = "brk8s20";
          Kind = "bridge";
          # MACAddress = "<TBD>";
        };
      };
    };

    networks = {
      "20-tailscale-ignore" = {
        matchConfig.Name = "tailscale*";
        linkConfig = {
          Unmanaged = "yes";
          RequiredForOnline = false;
        };
      };
      # TODO: change this to enp2s0 when installed to the new case
      "30-eno2" = {
        matchConfig.Name = "eno2"; # will eventually be enp2s0
        networkConfig = {
          Bridge = "br0";
          DHCP = "no";
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-vlk8s20" = {
        matchConfig = {Name = "vlk8s20";};
        networkConfig = {
          Bridge = "brk8s20";
        };
      };
      "50-br0" = {
        matchConfig.Name ="br0";
        networkConfig = {
          DHCP = "yes";
        };
        linkConfig = {
          # or "routable" with IP addresses configured
          RequiredForOnline = "carrier";
        };
      };
      "50-brk8s20" = {
        matchConfig.Name ="brk8s20";
        networkConfig = {
          DHCP = "yes";
        };
      };
      "99-network-defaults-wired" = {
        matchConfig.Name = "en* | eth* | usb*";
        networkConfig = {
          Description = "Fallback Wired DHCP";
          DHCP = "yes";
          IPForward = "yes";
        };
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
