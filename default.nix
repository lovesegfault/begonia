{ pkgs ? import ./nix }:
let
  generated = pkgs.callPackage ./Cargo.nix {
    inherit pkgs;
    defaultCrateOverrides = pkgs.defaultCrateOverrides // {
      openssl-sys = attrs: {
        buildInputs = with pkgs; [ openssl pkg-config ];
      };
    };
  };
  tested = generated.rootCrate.build.override {
    runTests = true;
    # testInputs = with pkgs; [ hello ];
  };
in
{
  inherit pkgs;
  begonia = tested;
  shellBuildInputs = with pkgs; [
    cachix
    cargo-edit
    crate2nix
    niv
    nixpkgs-fmt
    rustFull
  ];
}
