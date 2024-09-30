{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage {
  pname = "gunicornix";
  version = "0.0.1";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      #./djangunicornix
    ];
  };

  dependencies = with python3Packages; [
    django
  ];
}
