# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/pta2002/nixvim";
  });
}
