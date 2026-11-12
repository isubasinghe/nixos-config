-- Parsers are installed via :TSInstall or the build step in the lazy spec.
-- Run :TSInstall tlaplus go haskell rust javascript typescript agda bash bibtex capnp css devicetree llvm latex ledger lua make nix proto
-- to install any missing parsers.
return {
  { 'nvim-treesitter/nvim-treesitter', branch="main", build=":TSUpdate" },
}
