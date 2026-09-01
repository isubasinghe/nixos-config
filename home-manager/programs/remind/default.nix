{ config, lib, pkgs, ... }:

{
  options.custom.remind.workReminders = lib.mkEnableOption "work reminders file and notification daemon";

  config = {
    home.packages =
      [ pkgs.remind ]
      ++ lib.optionals config.custom.remind.workReminders [ pkgs.libnotify ];

    home.file.".reminders" = lib.mkIf config.custom.remind.workReminders {
      text = ''
        # Remind calendar - syntax: REM [date rules] AT hh:mm MSG text
        # See `man remind`. Today's agenda: `remind ~/.reminders`
        # Weekdays only: add day names, e.g. REM Mon Tue Wed Thu Fri AT 09:13 MSG ...

        # Daily standup at 09:23
        REM AT 09:13 MSG Standup in 10 minutes
        REM AT 09:18 MSG Standup in 5 minutes
        REM AT 09:22 MSG Standup in 1 minute

        # Log project tracking at end of working week
        REM Friday AT 16:00 MSG Log your project tracking
      '';
    };

    systemd.user.services.remind = lib.mkIf config.custom.remind.workReminders {
      Unit = {
        Description = "Remind daemon for timed desktop notifications";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.remind}/bin/remind -a -z -f \"-k:${pkgs.libnotify}/bin/notify-send -u critical %%s &\" ${config.home.homeDirectory}/.reminders";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
