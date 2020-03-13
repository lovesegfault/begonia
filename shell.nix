with (import ./. {});
pkgs.mkShell {
  name = "begonia";
  buildInputs = shellBuildInputs;
}
