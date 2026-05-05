{
  description = "aws-aurora development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devcontainer-env.url = "github:devcontainer-env/devcontainer-env";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      devcontainer-env,
      ...
    }:
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
          vendorHash = "sha256-D6XoJNXtJmz4I75FLU16qpK+EhRhVeMCCccddYuI2jA=";
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
          name = "aws-aurora";
          packages = [
            devcontainer-env.packages.${system}.default
            pkgs.go
          ];
          shellHook = ''
            eval "$(devcontainer-env export)"
          '';
        };
      }
    );
}
