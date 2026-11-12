{ config, lib, pkgs, ... }:

let
  notifyCommand = "${pkgs.libnotify}/bin/notify-send -u critical %%s &";

  # Minutes before an event for the first notification, and the interval
  # between the notifications that follow. The last one is at the start time.
  calendarLeadMinutes = 10;
  calendarRepeatMinutes = 5;

  # The khal config of the user, with fixed date and time formats added, so
  # that the output is the same in all locales.
  calendarKhalConfig = pkgs.writeText "khal-calendar-reminders.conf" ''
    ${config.xdg.configFile."khal/config".text}
    [locale]
    dateformat = %Y-%m-%d
    timeformat = %H:%M
  '';

  # Writes one remind entry for each timed event in the khal calendars, for
  # today and the 6 days that follow. All-day and cancelled events get no entry.
  calendarReminders = pkgs.writeShellApplication {
    name = "calendar-reminders";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      khal
    ];
    text = ''
      out="''${XDG_STATE_HOME:-$HOME/.local/state}/calendar-reminders/calendar.rem"
      mkdir -p "$(dirname "$out")"
      # The remind daemon must have a file to read, also when khal fails.
      [ -e "$out" ] || : >"$out"

      tmp=$(mktemp "$out.XXXXXX")
      trap 'rm -f "$tmp"' EXIT

      khal -c ${calendarKhalConfig} list --day-format "" \
        --format $'{start-date}\t{start-time}\t{all-day}\t{cancelled}\t{title}' \
        today 7d \
        | sort -u \
        | awk -F'\t' '
            $1 ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ &&
            $2 ~ /^[0-9][0-9]:[0-9][0-9]$/ &&
            $3 == "False" && $4 == "" {
              title = $5
              # These characters have a special function in a remind file.
              gsub(/%/, "%%", title)
              gsub(/\[/, "(", title)
              gsub(/\]/, ")", title)
              gsub(/\\/, "/", title)
              printf "REM %s AT %s +${toString calendarLeadMinutes} *${toString calendarRepeatMinutes} MSG %s %%1\n", $1, $2, title
            }
          ' >"$tmp"

      # Replace the file only when the entries changed. The remind daemon
      # reads the file again when its modification time changes.
      if ! cmp -s "$tmp" "$out"; then
        mv "$tmp" "$out"
      fi
    '';
  };
in
{
  options.custom.remind.workReminders = lib.mkEnableOption "work reminders file and notification daemon";
  options.custom.remind.calendarReminders = lib.mkEnableOption "desktop notifications for each timed event in the khal calendars";

  config = {
    home.packages =
      [ pkgs.remind ]
      ++ lib.optionals config.custom.remind.workReminders [ pkgs.libnotify ];

    home.file.".reminders" = lib.mkIf config.custom.remind.workReminders {
      text = ''
        # Remind calendar - syntax: REM [date rules] AT hh:mm MSG text
        # See `man remind`. Today's agenda: `remind ~/.reminders`
        # Weekdays only: add day names, e.g. REM Mon Tue Wed Thu Fri AT 09:13 MSG ...

        # Log project tracking at end of working week
        REM Friday AT 16:00 MSG Log your project tracking

        # Recap the day's activities (weekdays)
        REM Mon Tue Wed Thu Fri AT 17:00 MSG Recap the day's activities
      '';
    };

    systemd.user.services.remind = lib.mkIf config.custom.remind.workReminders {
      Unit = {
        Description = "Remind daemon for timed desktop notifications";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.remind}/bin/remind -a -z -f \"-k:${notifyCommand}\" ${config.home.homeDirectory}/.reminders";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.calendar-reminders = lib.mkIf config.custom.remind.calendarReminders {
      Unit.Description = "Write remind entries for the khal calendar events";
      Service = {
        Type = "oneshot";
        ExecStart = "${calendarReminders}/bin/calendar-reminders";
      };
    };

    systemd.user.timers.calendar-reminders = lib.mkIf config.custom.remind.calendarReminders {
      Unit.Description = "Update the calendar reminders periodically";
      Timer = {
        OnStartupSec = "1min";
        OnUnitActiveSec = "5min";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.remind-calendar = lib.mkIf config.custom.remind.calendarReminders {
      Unit = {
        Description = "Remind daemon for calendar event notifications";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStartPre = "-${calendarReminders}/bin/calendar-reminders";
        ExecStart = "${pkgs.remind}/bin/remind -a -z -f \"-k:${notifyCommand}\" %S/calendar-reminders/calendar.rem";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
