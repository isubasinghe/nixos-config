# Academic: proof assistants, theorem provers, LaTeX, formal methods
{ pkgs, ... }:

let
  z3-4-12-5 = pkgs.z3.overrideAttrs (old: rec {
    pname = "z3";
    src = pkgs.fetchFromGitHub {
      owner = "Z3Prover";
      repo = pname;
      rev = "z3-4.12.5";
      sha256 = "sha256-Qj9w5s02OSMQ2qA7HG7xNqQGaUacA1d4zbOHynq5k+A=";
    };
  });
in
{
  home.packages = with pkgs; [
    texlive.combined.scheme-full
    tikzit
    racket
    elan
    z3-4-12-5
    isabelle
    tlaplusToolbox
    (agda.withPackages (ps: [ ps.standard-library ]))
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    verible
    verilator
    leetcode-cli
  ];
}
