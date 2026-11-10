# Development tools: languages, LSPs, compilers, build tools
{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    go
    rustup
    (haskellPackages.ghcWithPackages (ps: [
      ps.shake
      ps.haskell-language-server
      ps.xmonad
      ps.X11
      ps.xmonad-contrib
      ps.xmonad-extras
      ps.dbus
      ps.turtle
      ps.stack
      ps.language-c
      ps.diagrams
      ps.diagrams-cairo
      ps.diagrams-svg
      ps.diagrams-contrib
      ps.megaparsec
      ps.happy
      ps.alex
    ]))
    gnumake
    ormolu
    nodejs
    yarn
    (python3.withPackages (p: with p; [
      jsonpatch
      requests
      pyyaml
      kubernetes
      deepdiff
      exrex
      jsonschema
      pandas
      tabulate
      pytest
      pydantic
      pytest-cov
      uv
      matplotlib
      networkx
      graphviz
      debugpy
    ]))
    gopls
    ccls
    typescript-language-server
    pyright
    gofumpt
    delve
    gdb
    gdlv
    gotools
    clang-tools
    texlab
    java-language-server
    nixd
    yamllint
    pkg-config
    openssl
    protobuf
    protoc-gen-go
    jdk17
    maven
    sbt
    metals
    scalafmt
    coursier
    scala-cli
    poetry
    tree-sitter
    vscode
    jetbrains.rust-rover
    jetbrains.idea
    valgrind
  ];

  # The nixpkgs rustup writes its own store path into the ld.lld wrapper of
  # each toolchain that it installs. After a rustup update and a garbage
  # collection, that path is gone and the toolchain cannot link. Point the
  # wrappers of all installed toolchains at the current rustup on each switch.
  home.activation.fixRustupLdWrappers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for d in "$HOME"/.rustup/toolchains/*/lib/rustlib/*/bin; do
      [ -f "$d/gcc-ld-unwrapped/ld.lld" ] && [ -f "$d/gcc-ld/ld.lld" ] || continue
      run ${pkgs.gnused}/bin/sed -i -E \
        's|/nix/store/[a-z0-9]{32}-rustup-[^/]+/|${pkgs.rustup}/|' "$d/gcc-ld/ld.lld"
    done
  '';
}
