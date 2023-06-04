{pkgs, ...}: 
{
  systemd.user.services.xmobar = {
    Unit.Description = "Script for running xmobar as a service";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${pkgs.xmobar}/bin/xmobar";
    };
  };
}
