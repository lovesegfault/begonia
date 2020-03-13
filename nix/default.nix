let
  sources = import ./sources.nix;
  overlays = [
    (import sources.nixpkgs-mozilla)
    (
      _: pkgs:
        let
          rustChannel = pkgs.rustChannelOf { channel = "stable"; };
          extensions = [
            "clippy-preview"
            "rls-preview"
            "rustfmt-preview"
            "rust-analysis"
            "rust-std"
            "rust-src"
          ];
        in {
          rustFull = rustChannel.rust.override { inherit extensions; };
        }
    )
  ];
in
import sources.nixpkgs { inherit overlays; }
