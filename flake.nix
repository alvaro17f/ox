{
  description = "ox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        name = "ox";

        pkgs = import nixpkgs { inherit system; };

        buildInputs = with pkgs; [
          odin
        ];

        LD_LIBRARY_PATH =
          with pkgs;
          "$LD_LIBRARY_PATH:${
            lib.makeLibraryPath [
              libGL
              xorg.libX11
              openssl
            ]
          }";
      in
      with pkgs;
      {
        packages.default = stdenv.mkDerivation {
          name = name;
          src = ./.;
          buildInputs = buildInputs;
          LD_LIBRARY_PATH = LD_LIBRARY_PATH;
          buildPhase = ''
            odin build . -out:${name}
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp ${name} $out/bin
          '';
        };

        devShells.default = mkShell {
          buildInputs = buildInputs;
          LD_LIBRARY_PATH = LD_LIBRARY_PATH;
        };
      }
    );
}
