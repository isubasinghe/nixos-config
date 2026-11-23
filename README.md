# nixos-config

## Usage 

### System config
`sudo nixos-rebuild switch --flake .#hostname`

### Home-manager config 
`home-manager switch --flake .#username@hostname`

For the first installation, run the following from this repository to use the
matching Home Manager and Nixpkgs versions in `flake.lock`:

```sh
hm_source=$(nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).inputs.home-manager.outPath')
hm_nixpkgs=$(nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).inputs.nixpkgs.outPath')
NIX_PATH="home-manager=$hm_source:nixpkgs=$hm_nixpkgs" nix-shell '<home-manager>' -A install
```

This bootstraps Home Manager using `~/.config/home-manager/home.nix`. Then apply
this repository's configuration, for example on Pop!_OS:

```sh
home-manager switch --flake .#isubasinghe@pop-os
```

Set `NIX_PATH` so the installer's child processes also use the pinned versions.
Running `nix-shell '<home-manager>' -A install` without this override uses your
channels instead of `flake.lock`. A newer Home Manager channel paired with an
older Nixpkgs channel can fail with `attribute 'genAttrs\u0027' missing`.

### Neovim plugins

Plugin versions are tracked in
`home-manager/programs/neovim/nvim/lazy-lock.json`. Home Manager deploys this
configuration, but does not update the plugin checkouts in
`~/.local/share/nvim/lazy`.

From this repository, update plugins using the writable source configuration:

```sh
XDG_CONFIG_HOME="$PWD/home-manager/programs/neovim" nvim --headless '+Lazy! update' '+qa!'
```

Review the lockfile diff, then apply your Home Manager configuration and restart
Neovim. To sync installed plugins to the tracked versions instead, use the same
command with `'+Lazy! restore'`. Running these commands against the source keeps
Lazy from trying to write the read-only lockfile deployed by Home Manager.

Editing shortcuts (`<leader>` is Space):

| Keys | Action |
|---|---|
| `ysiw)` / `yss)` | Surround a word / line with parentheses |
| `cs)"` / `ds"` | Change parentheses to quotes / remove surrounding quotes |
| Visual `S` then a delimiter | Surround the selection |
| `cia` / `daa` | Change inside an argument / delete an argument (mini.ai) |
| `gc{motion}` / `gcc` | Comment a motion / line using native Neovim commenting |
| `]c` / `[c` | Next / previous Git hunk (native motions in diff windows) |
| `<leader>gs` / `<leader>gr` | Stage or unstage / reset a hunk or visual selection |
| `<leader>gp` | Preview the Git hunk |
| `<leader>gb` / `<leader>gB` | Blame the current line / buffer |
| `ih` | Git hunk text object |
| Visual `<leader>bw` | Open the selected URL in Chawan (`cha`) |

Leap retains `s` and Normal-mode `S`; Harpoon retains `<leader>h` mappings.

## CLI tools reference

Packages come from `home-manager/packages/cli-tools.nix` (all hosts) and a few
module-specific ones noted below.

### AI agents
| Tool | Description |
|---|---|
| `codex` | OpenAI coding agent (cached Nixpkgs unstable package) |
| `opencode` | terminal coding agent |
| `copilot` | GitHub Copilot CLI (`copilot suggest`, `copilot explain`) |

### Files, search, inspection
| Tool | Description |
|---|---|
| `yazi` | TUI file manager |
| `fd` | fast `find` |
| `rg` / `ag` | fast grep (ripgrep / silver-searcher) |
| `bat` | cat with syntax highlighting |
| `dust` / `duf` | disk usage (du / df replacements) |
| `hexyl` / `bingrep` / `imhex` | hex viewers |
| `ouch` | compress/decompress anything (`ouch decompress x.tar.zst`) |
| `tldr` (tealdeer) | community man pages |

### Git
| Tool | Description |
|---|---|
| `gh` | GitHub CLI |
| `gitui` | TUI git client |
| `delta` | git diff pager |
| `scc` | code stats (lines, complexity) |

### Processes / system
| Tool | Description |
|---|---|
| `procs` | ps replacement |
| `htop` / `bottom` (`btm`) | process monitors |
| `lsof` | open files/sockets |
| `reptyr` / `screen` | steal/keep TTYs across disconnects |

### Shell conveniences
| Tool | Description |
|---|---|
| `fzf` | fuzzy finder |
| `mcfly` | smarter shell history |
| `z` (zoxide) | smart cd |
| `jq` | JSON processor |
| `croc` | send files to another machine |
| `xsel` / `xclip` | X clipboard |

### Network / crypto / secrets
| Tool | Description |
|---|---|
| `nmap` / `dig` | network discovery / DNS |
| `age` / `rage` | modern file encryption |
| `pass` | password store (`pass -c entry` copies to clipboard) |
| `secret-tool` is NOT installed - use `pass` |

### Nix
| Tool | Description |
|---|---|
| `nom` (nix-output-monitor) | pretty nix build output |
| `nix-index` | find packages containing a file |
| `cachix` | binary cache hosting |

### Mail / calendar / reminders
| Tool | Description |
|---|---|
| `himalaya` | CLI mail client (M365 work account via msgraph backend) |
| `ortie` | OAuth token manager backing himalaya (`ortie token show -a sqc`) |
| `remind` | reminders + calendar daemon (see below) |
| `gcal` | cal-style month view, marks today |
| `khal` | calendar (config + vdir are nix-managed) |
| `vdirsyncer` | CalDAV sync (needs `~/.config/vdirsyncer/config`) |
| `newsboat` | RSS reader (feed list is nix-managed) |
| `watson` | time tracking |
| `qalc` | unit-aware calculator |

### Docs
| Tool | Description |
|---|---|
| `typst` | modern LaTeX alternative |
| `pandoc` | universal document converter |
| `zathura` | minimal PDF viewer |

### Hyprland session (NixOS desktop and Precision laptop)

The `nixos` desktop shares Precision's Hyprland theme, keybindings, Rofi,
Waybar, notifications, clipboard, screenshots, and idle locking. DocSearch,
the Intel VA-API override, and laptop monitor assignments remain Precision-only.
Pop!_OS and `vb-100` keep their existing configurations.

On the NixOS desktop, apply both configurations:

```sh
sudo nixos-rebuild switch --flake .#nixos
home-manager switch --flake .#isithas@nixos
```

Log out and select **Hyprland** at the login screen. NixOS manages the session,
NVIDIA driver, desktop portals, and Hyprlock authentication; Home Manager manages
the desktop settings and user services.

`grim` + `slurp` (screenshots), `wl-clipboard` + `cliphist` (clipboard +
history), `brightnessctl`, `swaync-client -t` (notifications),
`nm-connection-editor` (network).

## Key workflows

**Reminders** — edit the `.reminders` text in
`home-manager/programs/remind/default.nix`, then `home-manager switch`. The
daemon (`-z`) re-reads the file within a minute, no restart needed. Today's
agenda: `remind ~/.reminders`. Reminders fire as critical notifications via
`notify-send`. Only the precision laptop runs the daemon
(`custom.remind.workReminders = true`); other hosts just get the binary.
Never edit `~/.reminders` directly - it is a symlink into the nix store.

**Calendar reminders** — with `custom.remind.calendarReminders = true`
(precision laptop only), each timed event in the khal calendars gets a
notification 10 and 5 minutes before the start, and at the start. The
`calendar-reminders` timer writes the events of the next 7 days to
`~/.local/state/calendar-reminders/calendar.rem` every 5 minutes, and the
`remind-calendar` daemon reads that file. All-day and cancelled events get
no notification.

**Mail** — himalaya's msgraph backend pulls tokens from ortie, which stores
them in `pass` as `ortie/sqc` (never edit that entry by hand). First-time
auth: `ortie auth get -a sqc`. Both `~/.config/himalaya/config.toml` and
`~/.config/ortie/config.toml` are unmanaged files on purpose so the wizards
can still edit them.
