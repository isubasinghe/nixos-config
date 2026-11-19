{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  # The laptop panel is always eDP-1. The external monitor name depends
  # on the cable/dock (DP-1 at the office, HDMI-A-1 at home), so the
  # Hyprland config finds it at runtime. `externalMonitors` is only the
  # list of names that waybar knows about; add a name here if a new
  # connector shows up in `hyprctl monitors`.
  internalMonitor = "eDP-1";
  externalMonitors = [ "DP-1" "DP-2" "HDMI-A-1" ];
  gnomeDisksPackage = config.lib.nixGL.wrap pkgs.gnome-disk-utility;
in
{
  imports = [
    ./programs/zsh
    ./programs/starship
    ./programs/tmux
    ./programs/zoxide
    ./programs/neovim
    ./programs/remind
    ./programs/wezterm
    ./programs/ghostty
    ./programs/xmonad
    ./programs/hyprland
    ./programs/xmobar
    ./packages/cli-tools.nix
    ./packages/dev-tools.nix
    ./packages/academic.nix
    ./profiles/common.nix
  ];

  custom.remind.workReminders = true;
  custom.remind.calendarReminders = true;
  custom.hyprland.docsearch.enable = true;

  # Hardware-specific settings stay on the Precision laptop.
  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    -- Pin workspaces to monitors so SUPER+1..5 always lives on the
    -- laptop and SUPER+6..0 always lives on the external monitor.
    -- Without `monitor`, Hyprland keeps a single global pool and
    -- `focus workspace` pulls the workspace to the current monitor
    -- (the swap you were seeing). With these rules, focusing a
    -- workspace bound to the other monitor jumps focus there instead.
    -- `persistent` keeps empty workspaces alive so each bar always
    -- shows its own set. `default` gives each monitor a workspace to
    -- fall back to on (re)connect.
    for i = 1, 5 do
      hl.workspace_rule({
        workspace = tostring(i),
        monitor = ${builtins.toJSON internalMonitor},
        persistent = true,
        default = (i == 1),
      })
    end
    -- The external monitor has a different connector name at each
    -- desk, so do not hardcode it. Bind workspaces 6..10 to the first
    -- monitor that is not the laptop panel, and do this again each
    -- time a monitor is connected or disconnected.
    local internal = ${builtins.toJSON internalMonitor}
    local function bind_external_workspaces()
      local external = nil
      for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= internal then
          external = m.name
          break
        end
      end
      for i = 6, 10 do
        hl.workspace_rule({
          workspace = tostring(i),
          monitor = external or ${builtins.toJSON (builtins.head externalMonitors)},
          persistent = true,
          default = (i == 6),
        })
        -- Workspaces that already exist stay on their old monitor
        -- unless they are moved.
        if external and hl.get_workspace(i) then
          hl.dispatch(hl.dsp.workspace.move({ workspace = i, monitor = external }))
        end
      end
    end
    bind_external_workspaces()
    hl.on("monitor.added", bind_external_workspaces)
    hl.on("monitor.removed", bind_external_workspaces)

    hl.env("LIBVA_DRIVER_NAME", "iHD")
  '';

  programs.waybar.settings.mainBar."hyprland/workspaces".persistent-workspaces = {
    "${internalMonitor}" = [ 1 2 3 4 5 ];
  } // lib.genAttrs externalMonitors (_: [ 6 7 8 9 10 ]);

  programs.git.settings.user.email = "isitha.subasinghe@sqc.com";

  nix.package = pkgs.nix;
  nix.settings.max-jobs = "auto";

  targets.genericLinux.enable = true;
  targets.genericLinux.nixGL = {
    packages = inputs.nixgl.packages;
    defaultWrapper = "mesa";
    offloadWrapper = "nvidiaPrime";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };

  home = {
    username = "isubasinghe";
    homeDirectory = "/home/isubasinghe";
    stateVersion = "24.05";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "/opt/vivado/2026.1/Vivado/bin"
  ];
  home.sessionVariablesExtra = lib.mkAfter ''
    export PATH="/opt/vivado/2026.1/Vivado/bin:$PATH"
  '';
  programs.zsh.initContent = lib.mkAfter ''
    path=($HOME/.local/bin $path /opt/vivado/2026.1/Vivado/bin)
    typeset -U path
  '';

  # This application is intentionally limited to the Dell Home Manager target.
  home.packages = [
    gnomeDisksPackage
    (config.lib.nixGL.wrap pkgs.slack)
    pkgs.openvpn
    pkgs.networkmanager-openvpn
    pkgs.act
    pkgs.devcontainer
  ];

  dconf.settings."org/gnome/desktop/default-applications/terminal" = {
    exec = "ghostty";
    exec-arg = "";
  };

  # Pull Outlook -> ~/Mail/sqc every 5 min. Uses the cached gpg passphrase,
  # so unlock `pass` once in a terminal after login (any `hm-sync` run).
  systemd.user.services.hm-sync = {
    Unit.Description = "Sync Outlook mail to local Maildir";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.nix-profile/bin/hm-sync";
    };
  };

  systemd.user.timers.hm-sync = {
    Unit.Description = "Sync Outlook mail periodically";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Pull M365 calendar -> khal vdir every 15 min. Reuses the ortie/sqc token
  # (already has Calendars.Read); needs `pass` unlocked like hm-sync.
  systemd.user.services.hm-cal-sync = {
    Unit.Description = "Sync M365 calendar to khal vdir";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.nix-profile/bin/hm-cal-sync";
    };
  };

  systemd.user.timers.hm-cal-sync = {
    Unit.Description = "Sync M365 calendar periodically";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "15min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
