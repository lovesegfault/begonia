let
  pkgs = import ./nix;
in
pkgs.mkShell {
  name = "chirp";
  buildInputs = with pkgs; [
    cargo-edit
    crate2nix
    niv
    rustFull
  ];
}
