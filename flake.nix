{
  description = "Django app packaged with gunicorn on NixOS";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-parts,
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
        {
          apps.default = {
            type = "app";
            program = self'.packages.poetry-gunicorn;
          };
          checks.djangunicornix = pkgs.callPackage ./test.nix {
            inherit self;
            inherit (self'.packages) djangunicornix;
          };
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [ config.treefmt.build.wrapper ];
            inputsFrom = [ self'.packages.default ];
          };
          packages = {
            default = self'.packages.djangunicornix;
            djangunicornix = pkgs.python3Packages.callPackage ./package.nix { };
            poetry-gunicorn = pkgs.writeShellApplication {
              name = "poetry-gunicorn";
              runtimeInputs = [ self'.packages.djangunicornix ];
              # Put here your dev gunicorn config
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
