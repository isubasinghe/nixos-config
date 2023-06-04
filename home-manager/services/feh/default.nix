{pkgs, ...}:
{
  systemd.user.services.feh = {
    Unit.Description = "Script for running feh";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${pkgs.feh}/bin/feh --bg-scale /home/isithas/wallpaper.jpeg";
    };
  };
}
