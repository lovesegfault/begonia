{ pkgs ? import ./nix }:
with builtins;
let
  ciPath = "./.github/workflows/ci.yml";
  mkJob = extraSteps: {
    runs-on = "ubuntu-latest";
    steps = [
      {
        name = "Checkout";
        uses = "actions/checkout@v2";
      }
      {
        name = "Nix";
        uses = "cachix/install-nix-action@v7";
      }
    ] ++ extraSteps;
  };
  ci = {
    name = "CI";
    on.push.branches = [ "*" ];
    on.pull_request.branches = [ "*" ];
    jobs = let
      cachix = { attributes ? null, skipNixBuild ? false }: {
        name = "Cachix";
        uses = "cachix/cachix-action@v4";
        "with" = {
          inherit attributes skipNixBuild;
          name = "begonia";
          signingKey = "'\${{ secrets.CACHIX_SIGNING_KEY }}'";
        };
      };
    in {
      parsing = mkJob [
        {
          name = "Parsing";
          run = "find . -name \"*.nix\" -exec nix-instantiate --parse --quiet {} >/dev/null +";
        }
      ];
      ci = mkJob [
        (cachix { skipNixBuild = true; })
        {
          name = "Check CI";
          run = ''
            cp ${ciPath} /tmp/ci.reference.yml
            nix-build ci.nix --no-out-link | bash
            diff ${ciPath} /tmp/ci.reference.yml || exit 1
          '';
        }
      ];
      lockfile = mkJob [
        (cachix { skipNixBuild = true; })
        {
          name = "Check Cargo.lock";
          run = ''
            cmpPath="$(mktemp -d actions.XXXXXXXX)"
            cp Cargo.lock "$cmpPath/reference.lock"
            nix-shell --run "cargo update"
            diff Cargo.lock "$cmpPath/reference.lock" || exit 1
          '';
        }
      ];
      crate2nix = mkJob [
        (cachix { skipNixBuild = true; })
        {
          name = "Check Cargo.nix";
          run = ''
            cmpPath="$(mktemp -d actions.XXXXXXXX)"
            cp Cargo.nix "$cmpPath/reference.nix"
            nix-shell --run "crate2nix generate"
            diff Cargo.nix "$cmpPath/reference.nix" || exit 1
          '';
        }
      ];
      build = mkJob [ (cachix { attributes = "begonia"; }) ];
      shell = mkJob [ (cachix { attributes = "shellBuildInputs"; }) ];
    };
  };
  generated = pkgs.writeText "ci.yml" (toJSON ci);
in
pkgs.writeShellScript "gen_ci" ''
  mkdir -p "$(dirname ${ciPath})"
  cat ${generated} > ${ciPath}
''
