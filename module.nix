{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.djangunicornix;

  configFile = pkgs.writeText "gunicorn.conf.py" ''
    accesslog = "${cfg.gunicorn.access-logfile}"
    bind = "${cfg.gunicorn.bind}"
    workers = ${cfg.gunicorn.workers}
    timeout = ${cfg.gunicorn.timeout}
    worker_class = "${cfg.gunicorn.worker-class}"
  '';
in
{
  options.djangunicornix = {
    enable = lib.mkEnableOption "djangunicornix service";
    package = lib.mkPackageOption pkgs "djangunicornix" { };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/djangunicornix";
      description = "Data directory for djangunicornix";
    };
    gunicorn = {
      access-logfile = lib.mkOption {
        type = lib.types.str;
        default = "-";
        description = ''
          The Access log file to write to.

          '-' means log to stdout.
        '';
      };
      listenAddress = lib.mkOptions {
        type = lib.types.str;
        default = "0.0.0.0";
      };
      port = lib.mkOptions {
        type = lib.types.int;
        default = "5000";
      };
      bind = lib.mkOptions {
        type = lib.types.str;
        default = "${cfg.gunicorn.listenAddress}:${cfg.gunicorn.port}";
        description = ''
          The socket to bind.

          A string of the form: HOST, HOST:PORT, unix:PATH, fd://FD. An IP is a valid HOST.
        '';
      };
      workers = lib.mkOptions {
        type = lib.types.int;
        default = 4;
        description = "The number of worker processes for handling requests.";
      };
      timeout = lib.mkOptions {
        type = lib.types.int;
        default = 90;
        description = "Workers silent for more than this many seconds are killed and restarted.";
      };
      worker-class = lib.mkOptions {
        type = lib.types.str;
        default = "uvicorn.workers.UvicornWorker";
        description = "The type of workers to use.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.users.djangunicornix = {
      description = "djangunicornix server user";
      home = "${cfg.dataDir}";
      createHome = true;
      group = "djangunicornix";
      uid = config.ids.uids.djangunicornix;
    };
    users.groups.djangunicornix.gid = config.ids.gids.djangunicornix;

    systemd.services.djangunicornix = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "gunicorn nix example";
      serviceConfig = {
        ExecStart = ''
          ${lib.getExe pkgs.python3Packages.gunicorn} \
          --config ${configFile} \
          djangunicornix.asgi:application"
        '';
        User = "djangunicornix";
        Group = "djangunicornix";
        WorkingDirectory = cfg.dataDir;
      };
    };
  };
}
