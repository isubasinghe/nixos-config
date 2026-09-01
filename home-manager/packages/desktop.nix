# Desktop: GUI applications, media, office
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    slack
    kitty
    cheese
    spotify
    vlc
    obs-studio
    libreoffice-qt
    zathura
    feh
    nautilus
    deluge
    arandr
    screenkey
    asciinema
    libnotify
    multilockscreen
    paprefs
    pavucontrol
    pasystray
    playerctl
    pulsemixer
    zotero
    insomnia
    godot_4
    distrobox
    virtualbox
  ];
}
