# djangunicornix

Django app packaged with gunicorn on NixOS

## Dev shell

`nix develop`, but you can automate this with [nix-direnv](https://github.com/nix-community/nix-direnv)

## Quick run

`nix run`

## Prod on nixos

Add `djangounicornix` nixos module, and enable `services.djangunicornix.enable` in your config.

Ref. the test in a VM (which can be launched with `nix flake check -L`).

## Prod on docker

```
nix build -L .#docker
docker load < result
docker run --rm -it -p 5000:5000 djangunicornix:latest
```
