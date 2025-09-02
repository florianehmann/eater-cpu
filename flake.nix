{
  description = "Verilog Simulation Environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      libs = [];

      ldLibPath = lib.concatStringsSep ":" (map (pkg: "${pkg}/lib") libs);

    in {
      devShells = {
        x86_64-linux = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              iverilog
              gtkwave
              logisim
            ] ++ libs;

            shellHook = ''
              export LD_LIBRARY_PATH=${ldLibPath}:$LD_LIBRARY_PATH
            '';
          };
        };
      };
    };
}
