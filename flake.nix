{
  description = "aws-aurora development shell";

  nixConfig = {
    extra-substituters = [ "https://nixos-contrib.cachix.org" ];
    extra-trusted-public-keys = [ "nixos-contrib.cachix.org-1:WRyXCyMQGjYEEC87RdlW4ZbK/R3Ia4/WGYEoIP9X/o0=" ];
  };

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
          vendorHash = "sha256-JU7AI/jn4OgSXux32y0ZZJII2SAY04nnMFvDY5TTVcw=";
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
