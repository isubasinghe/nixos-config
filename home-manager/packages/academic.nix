# Academic: proof assistants, theorem provers, LaTeX, formal methods
{ pkgs, ... }:

let
  agdaWithLibraries = pkgs.agda.withPackages (ps: [ ps.standard-library ]);

  # The pinned Nixpkgs ALS is an older, broken release. v11 supports Agda 2.8.0.
  agdaLanguageServer = pkgs.haskell.lib.overrideCabal pkgs.haskellPackages.agda-language-server (old: {
    version = "11";
    src = pkgs.fetchurl {
      url = "https://github.com/agda/agda-language-server/releases/download/v11/agda-language-server-11.tar.gz";
      hash = "sha256:5dd68e704335a86dd8a01ce4384867e0c0b2b1779d4aaf182cb350c1126744aa";
    };
    broken = false;
    configureFlags = (old.configureFlags or []) ++ [ "-fAgda-2-8-0" ];
    libraryHaskellDepends = old.libraryHaskellDepends ++ (with pkgs.haskellPackages; [
      directory filepath lsp-types prettyprinter
    ]);
    executableHaskellDepends = old.executableHaskellDepends ++ (with pkgs.haskellPackages; [
      directory filepath lsp-types prettyprinter
    ]);
    # ALS uses the same network-simple API provided by Nixpkgs' newer release.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace agda-language-server.cabal \
        --replace-fail 'network-simple ==0.4.2' 'network-simple >=0.4.2 && <0.5'
    '';
    # The release tarball omits test/data, which the upstream tests require.
    doCheck = false;
    executableToolDepends = (old.executableToolDepends or []) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/als \
        --add-flags "+AGDA --library-file=${agdaWithLibraries.libraryFile} -AGDA"
    '';
  });

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
    typst
    pandoc
    poppler-utils
    mupdf
    qpdf
    tesseract
    ocrmypdf
    zathura
    tikzit
    racket
    elan
    z3
    isabelle
    tlaplusToolbox
    idris2
    idris2Packages.idris2Lsp
    agdaWithLibraries
    agdaLanguageServer
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    verible
    verilator
    leetcode-cli
  ];
}
