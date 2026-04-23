{
  description = "aws-aurora development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = (pkgs.lib.importJSON ./.github/config/release-please-manifest.json).".";
      in
      {
        packages.default = pkgs.buildGoModule {
          pname = "aurora";
          inherit version;
          src = pkgs.lib.cleanSource ./.;
          subPackages = [ "cmd/aurora" ];
          vendorHash = "sha256-frC9/nSsiKtiTjrO07GzXTem1C6OBTIY2GrHetQDnQw=";
          doInstallCheck = true;
          installCheckPhase = ''
            $out/bin/aurora --help
          '';
          meta = with pkgs.lib; {
            description = "AWS Aurora schema migrations ";
            license = licenses.mit;
            mainProgram = "aurora";
          };
        };

        devShells.default = pkgs.mkShell {
          name = "aurora";
          packages = [
            pkgs.go
          ];
        };
      }
    );
}
