{
  pkgs,
  inputs,
  ...
}:
let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session}";
        user = "greeter";
      };
    };
  };

  # this is a life saver.
  # literally no documentation about this anywhere.
  # might be good to write about this...
  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  security.pam.services.regreet.enableGnomeKeyring = true;

  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "frappe";
      accent = "mauve";
      clockEnabled = true;
      userIcon = true;
      # font = "Noto Sans";
      # fontSize = "9";
      # background = "${./wallpaper.png}";
      # loginBackground = true;
    })
  ];
}
