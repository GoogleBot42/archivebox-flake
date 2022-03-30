{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      supportedSystems = with flake-utils.lib.system; [ x86_64-linux i686-linux aarch64-linux ];
    in {
      nixosModule = import ./module.nix;
    } // flake-utils.lib.eachSystem supportedSystems (system:
      {
        checks.install =
          with import (nixpkgs + "/nixos/lib/testing-python.nix") { inherit system; };
          simpleTest {
            machine = { config, pkgs, ... }: {
              imports = [ self.nixosModule ];

              virtualisation.memorySize = 256;

              services.archivebox.enable = true;
            };

            testScript = ''
              machine.wait_for_unit("archivebox")
            '';
          };
      }
    );
}