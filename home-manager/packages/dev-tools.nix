# Development tools: languages, LSPs, compilers, build tools
{ pkgs, ... }:

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
    ]))
    gnumake
    ormolu
    nodejs
    yarn
    (python311.withPackages (p: with p; [
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
    ]))
    gopls
    ccls
    (nodePackages.typescript-language-server)
    pyright
    gofumpt
    delve
    gdlv
    gotools
    clang-tools
    texlab
    java-language-server
    nixd
    gcc
    cmake
    pkg-config
    openssl
    protobuf
    protoc-gen-go
    jdk17
    maven
    sbt
    poetry
    tree-sitter
    vscode
    jetbrains.rust-rover
    jetbrains.idea-community
    valgrind
  ];
}
