{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";

    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full;
        };

        genshingothic =
          with pkgs;
          callPackage ./nix/font-genshingothic.nix {
            inherit stdenv fetchurl unzip;
          };

        fontsEnv = pkgs.buildEnv {
          name = "fonts-env";
          paths = with pkgs; [
            noto-fonts
            noto-fonts-emoji
            noto-fonts-cjk-serif
            noto-fonts-cjk-sans
            source-han-serif-japanese
            nerd-fonts.monaspace
            genshingothic
          ];
          pathsToLink = [ "/share/fonts" ];
        };

        formatter = pkgs.nixfmt-rfc-style;

      in
      {
        legacyPackages = pkgs;
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = [
            texlive
            pkgs.python3Packages.pygments

            pkgs.texlab

            pkgs.nil
            formatter
          ];
          FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ "${fontsEnv}/share/fonts" ]; };
          shellHook = ''
            export OSFONTDIR="${fontsEnv}/share/fonts"
            luaotfload-tool --update
          '';
        };
        inherit formatter;
      }
    );
}
