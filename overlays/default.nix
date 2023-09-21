# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: 
  let 
    nix-unstable = (import inputs.nixpkgs-unstable{ system = final.system; config.allowUnfree = true; });
  in
  {
    unstable = nix-unstable;
    csharp-ls = nix-unstable.csharp-ls;
    vscode-langservers-extracted = nix-unstable.vscode-langservers-extracted;
    nixd = nix-unstable.nixd;
  };
}
