{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    remind
    libnotify
  ];

  home.file.".reminders".text = ''
    # Remind calendar - syntax: REM [date rules] AT hh:mm MSG text
    # See `man remind`. Today's agenda: `remind ~/.reminders`
    # Weekdays only: add day names, e.g. REM Mon Tue Wed Thu Fri AT 09:13 MSG ...

    # Daily standup at 09:23
    REM AT 09:13 MSG Standup in 10 minutes
    REM AT 09:18 MSG Standup in 5 minutes
    REM AT 09:22 MSG Standup in 1 minute
  '';

  systemd.user.services.remind = {
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
}
