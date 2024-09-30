{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "gunicornix";
  version = "0.0.1";
  pyproject = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./djangunicornix
      ./pyproject.toml
      ./README.md
    ];
  };

  build-system = with python3Packages; [
    poetry-core
  ];
  dependencies = with python3Packages; [
    django
    gunicorn
    uvicorn
  ];
}
