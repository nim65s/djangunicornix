# djangunicornix

Django app packaged with gunicorn on NixOS

## Dev shell

`nix develop`, but you can automate this with [nix-direnv](https://github.com/nix-community/nix-direnv)

## Quick run

`nix run`

## Prod on nixos

Add `djangounicornix` nixos module, and enable `services.djangunicornix.enable` in your config.

Ref. the test in a VM.
