let
  pkgs = import ./nix;
in
pkgs.mkShell {
  name = "begonia";
  buildInputs = with pkgs; [
    cargo-edit
    crate2nix
    niv
    rustFull
  ];
}
