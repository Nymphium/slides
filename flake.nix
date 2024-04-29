{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fonts = with pkgs; [
          noto-fonts-cjk
          noto-fonts-emoji
          pkgs.callPackage ./nix/font-genshingothic.nix {}
        ];
      in
      {
        legacyPackages = pkgs;
        devShells.default =
          pkgs.mkShell {
            buildInputs = fonts ++ [
              pkgs.texlive.combined.scheme-full
              pkgs.nil pkgs.nixpkgs-fmt
            ];
          };
        formatter = pkgs.nixpkgs-fmt;
      });
}
