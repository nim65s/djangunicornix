# djangunicornix

Django app packaged with gunicorn on NixOS

## Dev shell

`nix develop`, but you can automate this with [nix-direnv](https://github.com/nix-community/nix-direnv)

## Quick run

```
poetry run gunicorn --access-logfile - --bind 0.0.0.0:5000 --workers 4 -k uvicorn.workers.UvicornWorker djangunicornix.asgi:application --timeout 90
```
