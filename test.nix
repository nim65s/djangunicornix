{
  djangunicornix,
  pkgs,
  self,
}:

pkgs.nixosTest {
  name = "hello-boots";
  nodes.machine = _: {
    imports = [ self.nixosModules.djangunicornix ];
    services.djangunicornix = {
      enable = true;
      package = djangunicornix;
    };
    system.stateVersion = "24.05";
  };

  testScript = ''
    machine.wait_for_unit("gunicornix.service")
    machine.wait_for_open_port(5000)
  '';
}
