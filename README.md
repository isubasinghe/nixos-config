# nixos-config

## Usage 

### System config
`sudo nixos-rebuild switch --flake .#hostname`

### Home-manager config 
`home-manager switch --flake .#username@hostname`

## CLI tools reference

Packages come from `home-manager/packages/cli-tools.nix` (all hosts) and a few
module-specific ones noted below.

### AI agents
| Tool | Description |
|---|---|
| `codex` | OpenAI coding agent |
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

### Hyprland session (precision laptop)
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

**Mail** — himalaya's msgraph backend pulls tokens from ortie, which stores
them in `pass` as `ortie/sqc` (never edit that entry by hand). First-time
auth: `ortie auth get -a sqc`. Both `~/.config/himalaya/config.toml` and
`~/.config/ortie/config.toml` are unmanaged files on purpose so the wizards
can still edit them.
