{ config, pkgs, ... }:

let
  inherit (config.colorscheme) palette;

  wallpaper = ../../../imgs/wallpaper.jpeg;
  bluemanPackage = config.lib.nixGL.wrap pkgs.blueman;
  flameshotPackage = config.lib.nixGL.wrap pkgs.flameshot;
  hyprlandPackage = config.lib.nixGL.wrap pkgs.hyprland;
  hypridlePackage = pkgs.hypridle;
  hyprlockPackage = config.lib.nixGL.wrap pkgs.hyprlock;
  rofiPackage = config.lib.nixGL.wrap pkgs.rofi;
  swayncPackage = config.lib.nixGL.wrap pkgs.swaynotificationcenter;
  waybarPackage = config.lib.nixGL.wrap pkgs.waybar;

  hyprlock = "${hyprlockPackage}/bin/hyprlock";
  terminal = "${config.programs.wezterm.package}/bin/wezterm";
  launcher = "${rofiPackage}/bin/rofi -show drun";

  # Confirmed via `hyprctl monitors`: laptop panel is eDP-1, external
  # over your current dock/cable is DP-1. If you switch cables/docks and
  # the external shows up as HDMI-A-1 etc., update this one line.
  internalMonitor = "eDP-1";
  externalMonitor = "DP-1";
in
{
  home.packages = with pkgs; [
    brightnessctl
    grim
    hyprpicker
    networkmanagerapplet
    polkit_gnome
    slurp
    swaybg
    wl-clipboard
    rofiPackage
    bluemanPackage
  ];

  wayland.systemd.target = "hyprland-session.target";

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;
    configType = "lua";
    systemd.enable = true;
    systemd.enableXdgAutostart = true;
    xwayland.enable = true;

    extraConfig = ''
      local mod = "SUPER"
      local terminal = ${builtins.toJSON terminal}
      local launcher = ${builtins.toJSON launcher}

      hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = 1,
      })

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
      for i = 6, 10 do
        hl.workspace_rule({
          workspace = tostring(i),
          monitor = ${builtins.toJSON externalMonitor},
          persistent = true,
          default = (i == 6),
        })
      end

      hl.env("GDK_BACKEND", "wayland,x11,*")
      hl.env("LIBVA_DRIVER_NAME", "iHD")
      hl.env("MOZ_ENABLE_WAYLAND", "1")
      hl.env("NIXOS_OZONE_WL", "1")
      hl.env("QT_QPA_PLATFORM", "wayland;xcb")
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_TYPE", "wayland")

      hl.config({
        general = {
          gaps_in = 6,
          gaps_out = 12,
          border_size = 2,
          col = {
            active_border = {
              colors = { "rgb(${palette.base0E})", "rgb(${palette.base0D})" },
              angle = 45,
            },
            inactive_border = "rgb(${palette.base02})",
          },
          resize_on_border = true,
          layout = "dwindle",
          allow_tearing = false,
        },
        decoration = {
          rounding = 12,
          rounding_power = 3,
          active_opacity = 0.96,
          inactive_opacity = 0.90,
          fullscreen_opacity = 1.0,
          shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(${palette.base00}cc)",
          },
          blur = {
            enabled = true,
            size = 8,
            passes = 3,
            vibrancy = 0.18,
            new_optimizations = true,
          },
        },
        animations = {
          enabled = true,
        },
        dwindle = {
          preserve_split = true,
          smart_split = true,
        },
        input = {
          kb_layout = "us",
          follow_mouse = 1,
          sensitivity = 0,
          touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
          },
        },
        misc = {
          disable_hyprland_logo = true,
          disable_splash_rendering = true,
          disable_watchdog_warning = true,
          force_default_wallpaper = 0,
          animate_manual_resizes = true,
          focus_on_activate = true,
        },
      })

      hl.curve("easeOutQuint", {
        type = "bezier",
        points = { { 0.23, 1 }, { 0.32, 1 } },
      })
      hl.curve("easeInOutCubic", {
        type = "bezier",
        points = { { 0.65, 0.05 }, { 0.36, 1 } },
      })
      hl.animation({
        leaf = "windows",
        enabled = true,
        speed = 5,
        bezier = "easeOutQuint",
        style = "popin 85%",
      })
      hl.animation({
        leaf = "windowsOut",
        enabled = true,
        speed = 4,
        bezier = "easeInOutCubic",
        style = "popin 85%",
      })
      hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "easeOutQuint" })
      hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "easeOutQuint" })
      hl.animation({
        leaf = "workspaces",
        enabled = true,
        speed = 5,
        bezier = "easeOutQuint",
        style = "slide",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("${pkgs.networkmanagerapplet}/bin/nm-applet --indicator")
        hl.exec_cmd("${bluemanPackage}/bin/blueman-applet")
        hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
        hl.exec_cmd("${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill")
        hl.exec_cmd("${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store")
        hl.exec_cmd("${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store")
      end)

      hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
      hl.bind(mod .. " + D", hl.dsp.exec_cmd(launcher))
      hl.bind(mod .. " + E", hl.dsp.exec_cmd("${pkgs.nautilus}/bin/nautilus"))
      hl.bind(mod .. " + Q", hl.dsp.window.close())
      hl.bind(mod .. " + V", hl.dsp.window.float())
      hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
      hl.bind(mod .. " + P", hl.dsp.window.pseudo())
      hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
      hl.bind(mod .. " + L", hl.dsp.exec_cmd("${hyprlock}"))
      hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
      hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
      hl.bind(mod .. " + N", hl.dsp.exec_cmd("${swayncPackage}/bin/swaync-client -t"))
      hl.bind(mod .. " + C", hl.dsp.exec_cmd(
        "${pkgs.cliphist}/bin/cliphist list | ${rofiPackage}/bin/rofi -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
      ))
      hl.bind("Print", hl.dsp.exec_cmd(
        "${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy"
      ))
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
      ]]))
      hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("${flameshotPackage}/bin/flameshot gui"))

      hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
      hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
      hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
      hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
      hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
      hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

      for i = 1, 10 do
        local key = i % 10
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(
        "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
      ), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(
        "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd(
        "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ), { locked = true })
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(
        "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ), { locked = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(
        "${pkgs.brightnessctl}/bin/brightnessctl set +5%"
      ), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(
        "${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
      ), { locked = true, repeating = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(
        "${pkgs.playerctl}/bin/playerctl play-pause"
      ), { locked = true })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd(
        "${pkgs.playerctl}/bin/playerctl next"
      ), { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(
        "${pkgs.playerctl}/bin/playerctl previous"
      ), { locked = true })

      hl.window_rule({
        name = "suppress-maximize",
        match = { class = ".*" },
        suppress_event = "maximize",
      })
      hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true })
      hl.window_rule({ match = { class = "blueman-manager" }, float = true })
      hl.window_rule({ match = { class = "pavucontrol" }, float = true })
      hl.window_rule({ match = { class = "firefox" }, opacity = "1.0 override" })

      hl.layer_rule({
        match = { namespace = "waybar" },
        blur = true,
        ignore_alpha = 0.1,
      })
      hl.layer_rule({
        match = { namespace = "notifications" },
        blur = true,
      })
    '';
  };

  programs.hyprlock = {
    enable = true;
    package = hyprlockPackage;
    settings = {
      general = {
        hide_cursor = true;
        grace = 2;
        ignore_empty_input = true;
      };
      background = [
        {
          monitor = "";
          path = "${wallpaper}";
          blur_passes = 3;
          blur_size = 8;
          color = "rgb(${palette.base00})";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "300, 56";
          position = "0, -80";
          outline_thickness = 3;
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "Password...";
          font_color = "rgb(${palette.base05})";
          inner_color = "rgba(${palette.base00}dd)";
          outer_color = "rgb(${palette.base0E})";
          check_color = "rgb(${palette.base0D})";
          fail_color = "rgb(${palette.base08})";
          rounding = 14;
          shadow_passes = 2;
          ignore_empty_input = true;
        }
      ];
      label = [
        {
          monitor = "";
          text = "$TIME";
          color = "rgb(${palette.base05})";
          font_size = 64;
          font_family = "FiraCode Nerd Font";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date '+%A, %B %d'";
          color = "rgb(${palette.base04})";
          font_size = 18;
          font_family = "FiraCode Nerd Font";
          position = "0, 60";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    package = hypridlePackage;
    systemdTarget = "hyprland-session.target";
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${hyprlock}";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = hyprlock;
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.waybar = {
    enable = true;
    package = waybarPackage;
    systemd.enable = true;
    systemd.targets = [ "hyprland-session.target" ];
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 36;
      margin = "8 12 0";
      spacing = 6;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "network"
        "pulseaudio"
        "cpu"
        "memory"
        "temperature"
        "battery"
        "custom/notifications"
      ];

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
        persistent-workspaces = {
          "${internalMonitor}" = [ 1 2 3 4 5 ];
          "${externalMonitor}" = [ 6 7 8 9 10 ];
        };
      };
      "hyprland/window" = {
        format = "{title}";
        max-length = 55;
        separate-outputs = true;
      };
      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A, %d %B %Y}";
        tooltip-format = "<tt>{calendar}</tt>";
      };
      network = {
        format-wifi = "NET {essid} {signalStrength}%";
        format-ethernet = "NET wired";
        format-disconnected = "NET off";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      };
      pulseaudio = {
        format = "VOL {volume}%";
        format-muted = "VOL mute";
        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      cpu = {
        format = "CPU {usage}%";
        interval = 5;
      };
      memory = {
        format = "RAM {percentage}%";
        interval = 5;
      };
      temperature = {
        format = "TMP {temperatureC}C";
        critical-threshold = 85;
      };
      battery = {
        format = "BAT {capacity}%";
        format-charging = "BAT +{capacity}%";
        states = {
          warning = 30;
          critical = 15;
        };
      };
      tray.spacing = 8;
      "custom/notifications" = {
        format = "!";
        tooltip = false;
        on-click = "${swayncPackage}/bin/swaync-client -t";
        on-click-right = "${swayncPackage}/bin/swaync-client -C";
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "FiraCode Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: alpha(#${palette.base00}, 0.86);
        color: #${palette.base05};
        border: 1px solid #${palette.base02};
        border-radius: 14px;
      }

      #workspaces {
        margin: 5px;
      }

      #workspaces button {
        padding: 0 10px;
        color: #${palette.base04};
        border-radius: 10px;
      }

      #workspaces button.active {
        color: #${palette.base00};
        background: linear-gradient(90deg, #${palette.base0E}, #${palette.base0D});
      }

      #workspaces button.urgent {
        color: #${palette.base00};
        background: #${palette.base08};
      }

      #window {
        color: #${palette.base04};
        margin-left: 8px;
      }

      #clock,
      #tray,
      #network,
      #pulseaudio,
      #cpu,
      #memory,
      #temperature,
      #battery,
      #custom-notifications {
        margin: 5px 2px;
        padding: 0 10px;
        background: #${palette.base01};
        border-radius: 10px;
      }

      #clock {
        color: #${palette.base0E};
        font-weight: bold;
      }

      #network { color: #${palette.base0C}; }
      #pulseaudio { color: #${palette.base0D}; }
      #cpu { color: #${palette.base0B}; }
      #memory { color: #${palette.base0A}; }
      #temperature { color: #${palette.base09}; }
      #battery { color: #${palette.base0B}; }
      #battery.warning { color: #${palette.base09}; }
      #battery.critical { color: #${palette.base08}; }
      #custom-notifications { color: #${palette.base0E}; margin-right: 5px; }
    '';
  };

  services.swaync = {
    enable = true;
    package = swayncPackage;
  };

  xdg.configFile = {
    "rofi/config.rasi".text = ''
      configuration {
        modi: "drun,run,window";
        show-icons: true;
        display-drun: "Apps";
        terminal: "${terminal}";
        drun-display-format: "{name}";
      }
      @theme "porple"
    '';

    "rofi/porple.rasi".text = ''
      * {
        bg: #${palette.base00}ee;
        bg-alt: #${palette.base01};
        fg: #${palette.base05};
        muted: #${palette.base03};
        accent: #${palette.base0E};
        urgent: #${palette.base08};
      }

      window {
        width: 40%;
        border: 2px;
        border-color: @accent;
        border-radius: 16px;
        background-color: @bg;
        padding: 16px;
      }

      inputbar {
        children: [ prompt, entry ];
        background-color: @bg-alt;
        border-radius: 10px;
        padding: 12px;
        text-color: @fg;
      }

      prompt { text-color: @accent; padding: 0 10px 0 0; }
      entry { text-color: @fg; }
      listview { lines: 8; columns: 1; spacing: 6px; margin: 12px 0 0; }
      element { padding: 10px; border-radius: 10px; }
      element-text { text-color: @fg; }
      element-icon { size: 24px; margin: 0 10px 0 0; }
      element selected { background-color: @accent; }
      element selected element-text { text-color: @bg; }
    '';

    "swaync/config.json".text = builtins.toJSON {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-margin-top = 12;
      control-center-margin-right = 12;
      control-center-width = 420;
      notification-window-width = 420;
      timeout = 6;
      timeout-low = 3;
      timeout-critical = 0;
      widgets = [
        "title"
        "dnd"
        "notifications"
      ];
    };

    "swaync/style.css".text = ''
      * {
        font-family: "FiraCode Nerd Font", monospace;
        color: #${palette.base05};
      }

      .control-center,
      .notification-row .notification-background {
        background: alpha(#${palette.base00}, 0.94);
        border: 1px solid #${palette.base02};
        border-radius: 16px;
      }

      .control-center {
        padding: 12px;
      }

      .notification {
        padding: 12px;
        margin: 6px;
        border-radius: 12px;
      }

      .notification.critical {
        border: 2px solid #${palette.base08};
      }

      .summary {
        color: #${palette.base0E};
        font-weight: bold;
      }

      .body {
        color: #${palette.base04};
      }

      .widget-title {
        color: #${palette.base0D};
        font-size: 18px;
        margin: 8px;
      }

      .widget-dnd {
        background: #${palette.base01};
        border-radius: 10px;
        margin: 8px;
        padding: 8px;
      }
    '';
  };
}
