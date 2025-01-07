{ config, lib, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # GNOME options
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "fr";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # GNOME configuration
  # Excluding GNOME Applications
  environment.gnome.excludePackages = with pkgs; [
    geary
    gnome-tour
    epiphany
    gnome-boxes
    gnome-characters
    gnome-music
    simple-scan
    totem
    yelp
  ];

  # Managing Extensions & Applications
  environment.systemPackages = with pkgs; [
    dconf-editor
    gnomeExtensions.appindicator
    gnomeExtensions.background-logo
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.just-perfection
    gnomeExtensions.pop-shell
    gnomeExtensions.space-bar
    gnome-tweaks
    gnome-usage
    gnome-extension-manager
    songrec
    vlc
  ];

  # DCONF
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true; # prevents overriding
        settings = {
          # Boutons de fenêtre + Désactivation des sons système
          "org/gnome/desktop/wm/preferences" = {
            button-layout = ":minimize,maximize,close";
            audible-bell = false;
          };
          # Suramplification
          "org/gnome/desktop/sound" = {
            allow-volume-above-100-percent = true;
          };
          # Détacher les popups des fenêtres
          "org/gnome/mutter" = {
            attach-modal-dialogs = false;
          };
          # Affichage du calendrier dans le panneau supérieur
          "org/gnome/desktop/calendar" = {
            show-weekdate = true;
          };
          # Modification du format de la date et heure
          "org/gnome/desktop/interface" = {
            clock-show-date = true;
            clock-show-seconds = true;
            clock-show-weekday = true;
            clock-format = "24h";
          };
          # Paramétrage Touch Pad
          "org/gnome/desktop/peripherals/touchpad " = {
            disable-while-typing = true;
            click-method = "areas";
          };
          # Activation du mode nuit
          "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
          };
          # Epuration des fichiers temporaires et de la corbeille de plus de 30 jours
          "org/gnome/desktop/privacy" = {
            remove-old-temp-files = true;
            remove-old-trash-files = true;
            old-files-age = "30";
          };
          # Configuration de GNOME Text Editor
          "org/gnome/TextEditor" = {
            highlight-current-line = false;
            restore-session = false;
            show-line-numbers = true;
          };
          # Suppression de l'icône de la corbeille du dock
          "org/gnome/shell/extensions/dash-to-dock" = {
            show-trash = false;
          }; 
        };
      }
    ];
  };
}