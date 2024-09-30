{
  djangunicornix-nix,
  pkgs,
  self,
}:

pkgs.nixosTest {
  name = "djangunicornix";
  nodes.machine = _: {
    imports = [ self.nixosModules.djangunicornix ];
    environment.systemPackages = [ pkgs.curl ];
    services.djangunicornix = {
      enable = true;
      package = djangunicornix-nix;
    };
    system.stateVersion = "24.05";
  };

  testScript = ''
    machine.start()
    machine.wait_for_open_port(5000)

    title = "The install worked successfully! Congratulations!"
    content = machine.succeed("curl http://localhost:5000")
    if title not in content:
        err = f"{title=} not found in: \n{content=}"
        raise Exception(err)
  '';
}
