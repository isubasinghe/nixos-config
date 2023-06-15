{ pkgs, ... }: 
{ 
  programs.xmobar= {
    enable = true;
    extraConfig = ''
      Config
          { font        = "JetBrains Mono"
          , borderColor = "#d0d0d0"
          , border      = FullB
          , borderWidth = 0
          , bgColor     = "#222"
          , fgColor     = "grey"
          , position    = TopSize C 99 30
          , commands    =
              [ Run Cpu ["-t", "cpu: <fc=#4eb4fa><bar> <total>%</fc>"] 10
              , Run Network "enp3s0" ["-S", "True", "-t", "eth: <fc=#4eb4fa><rx></fc>/<fc=#4eb4fa><tx></fc>"] 10
              , Run Memory ["-t","mem: <fc=#4eb4fa><usedbar> <usedratio>%</fc>"] 10
              , Run Date "date: <fc=#4eb4fa>%a %d %b %Y %H:%M:%S </fc>" "date" 10
              , Run Weather "YSSY"
                        [ "--template", "<weather> <tempC>°C"
                        , "-L", "0"
                        , "-H", "25"
                        , "--low"   , "lightblue"
                        , "--normal", "#f8f8f2"
                        , "--high"  , "red"
                        ] 36000
              , Run StdinReader
              , Run XMonadLog
              ]
          , sepChar     = "%"
          , alignSep    = "}{"
          , template    = " %XMonadLog% }{ | %cpu% | %memory% | %date%  | %YSSY% "
      }
    '';
  };
}
