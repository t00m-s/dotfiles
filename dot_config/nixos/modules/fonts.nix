{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    # Modern individual package format
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    # Base Fonts (CRITICAL: Firefox needs these if they are set as defaults)
    noto-fonts

    # Emoji Support
    noto-fonts-color-emoji
    twemoji-color-font
  ];

  # Direct system to look at emojis properly
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FiraCode Nerd Font" "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
      sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
      serif = [ "Noto Serif" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
