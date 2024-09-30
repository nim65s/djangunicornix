{
  description = "Django app packaged with gunicorn on NixOS";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-parts,
      poetry2nix,
      treefmt-nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ treefmt-nix.flakeModule ];
      systems = [ "x86_64-linux" ];
      flake = {
        nixosModules.djangunicornix = import ./module.nix;
      };
      perSystem =
        {
          config,
          pkgs,
          self',
          ...
        }:
        let
          inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
        in
        {
          apps.default = {
            type = "app";
            program = self'.packages.poetry-gunicorn;
          };
          checks.djangunicornix = pkgs.callPackage ./test.nix {
            inherit self;
            inherit (self'.packages) djangunicornix-nix;
          };
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [ config.treefmt.build.wrapper ];
            inputsFrom = [ self'.packages.default ];
          };
          packages = {
            default = self'.packages.djangunicornix-poetry;
            djangunicornix-nix = pkgs.python3Packages.callPackage ./package.nix { };
            djangunicornix-poetry = mkPoetryApplication { projectDir = ./.; };
            docker = pkgs.dockerTools.buildLayeredImage {
              name = "djangunicornix";
              tag = "latest";
              contents = [
                pkgs.poetry
                self'.packages.djangunicornix-poetry.dependencyEnv
              ];
              config = {
                Cmd = pkgs.lib.getExe self'.packages.poetry-gunicorn;
                WorkingDir = "${self'.packages.djangunicornix-poetry.src}";
              };
            };
            poetry-gunicorn = pkgs.writeShellApplication {
              name = "poetry-gunicorn";
              runtimeInputs = [ self'.packages.djangunicornix-poetry ];
              text = ''
                poetry run gunicorn \
                  --access-logfile - \
                  --bind 0.0.0.0:5000 \
                  --workers 4 \
                  --timeout 90 \
                  -k uvicorn.workers.UvicornWorker \
                  djangunicornix.asgi:application
              '';
            };
          };
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              deadnix.enable = true;
              mdformat.enable = true;
              nixfmt.enable = true;
              ruff-check.enable = true;
              ruff-format.enable = true;
              toml-sort = {
                enable = true;
                all = true;
              };
            };
          };
        };
    };
}
