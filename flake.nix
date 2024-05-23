{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full fontspec;
        };

        genshingothic = with pkgs; callPackage ./nix/font-genshingothic.nix {
          inherit stdenv fetchurl unzip;
        };

        monaspice = with pkgs; callPackage ./nix/font-monaspice.nix {
          inherit stdenv fetchurl unzip;
        };

        fonts = with pkgs; [
          noto-fonts-cjk
          noto-fonts-emoji
          genshingothic
          monaspice
        ];
        OSFONTDIR = builtins.concatStringsSep ":" fonts;

      in
      {
        legacyPackages = pkgs;
        devShells.default =
          pkgs.mkShell {
            buildInputs = [
              texlive
              pkgs.python3Packages.pygments
              pkgs.nil pkgs.nixpkgs-fmt
            ];
            shellHook = ''
              export OSFONTDIR=${OSFONTDIR}
              luaotfload-tool --update
            '';
          };
        formatter = pkgs.nixpkgs-fmt;
      });
}
