# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./desktop-environment/gnome.nix
      # ./desktop-environment/kde.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System
  zramSwap.enable = true;
  boot.kernel.sysctl = { "vm.swappiness" = 10; };

  # Packages Repo
  nixpkgs.config.allowUnfree = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking = {
    hostName = "nixos";
    firewall.enable = false;
    nameservers = [ "192.168.20.115" "192.168.20.116" ];	

    interfaces = {
      enp0s3 = {
        useDHCP = true;
      };
      enp0s8 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "10.10.22.103";
          prefixLength = 24;
        }];	    
      };
    };
	
    defaultGateway = {
      address = "10.10.22.126";
      interface = "enp0s8";
    };
  };  

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.allfab = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    description = "Fabien";
    packages = with pkgs; [
      tree
    ];
  };

  # Linux Environment
  environment.shellAliases = {
    "ls" = "ls --color=auto";
    "ll" = "ls -hl --color=auto";
    "la" = "ls -hal --color=auto";
    "c" = "clear";
    "grep" = "grep --color=aut";
    "mkdir" = "mkdir -pv";
    "dcp" = "docker compose up -d";
    "dcd" = "docker compose dow";
    "dtail" = "docker logs -tf --tail='50'";
  };
  # set vim as default editor
  environment.variables = { EDITOR = "vim"; };

  # Programs with options
  programs.firefox.enable = true;
  programs.htop.enable = true;
  programs.htop.settings = {
    column_meters_0="System AllCPUs Memory Swap Zram";
    column_meter_modes_0="2 1 1 1 1";
    column_meters_1="SELinux Tasks LoadAverage Uptime";
    column_meter_modes_1="2 2 2 2";
  };
  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  # programs.vim.enable = true;
  # programs.vim.package = pkgs.vim-full;
  # programs.vim.defaultEditor = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    duf
    ghostty
    git
    nmon
    (import ./apps/vim/default.nix)
    wget
  ];

  # Run non-nix executables
  programs.nix-ld.enable = true;
  # programs.nix-ld.package = pkgs.nix-ld-rs;
  # programs.nix-ld.libraries = with pkgs; [
    ## Add any missing dynamic libraries for unpackaged programs
    ## here, NOT in environment.systemPackages
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Virtualisation
  # services.qemuGuest.enable = true;
  # virtualisation.virtualbox.guest.enable = true;

  # List services that you want to enable:
 
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}