let
  pkgs = import ./nix;
in
pkgs.mkShell {
  name = "begonia";
  buildInputs = with pkgs; [
    cachix
    cargo-edit
    crate2nix
    niv
    nixpkgs-fmt
    rustFull
  ];
}
