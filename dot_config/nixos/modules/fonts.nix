{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    noto-fonts

    noto-fonts-color-emoji
    twemoji-color-font
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "FiraCode Nerd Font"
        "JetBrainsMono Nerd Font"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Color Emoji"
      ];
      serif = [
        "Noto Serif"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
