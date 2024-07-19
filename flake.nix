{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    deno-overlay.url = "github:haruki7049/deno-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, deno-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ (import deno-overlay) ]; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        denoVersion = "1.45.2";
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.deno."${denoVersion}"
          ];

          shellHook = ''
            export PS1="\n[nix-shell:\w]$ "
          '';
        };
      }
    );
}
