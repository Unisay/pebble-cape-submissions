{
  description = "Dev shell providing Bun";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ bun nodejs_22 git pkg-config openssl aiken ];

          shellHook = ''
            echo "Entering Bun + Node dev shell for ${system}"
            bun --version
            node --version
            aiken --version
          '';
        };
      });
}
