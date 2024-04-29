{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "font-genshingothic";
  version = "20150607";

  src = fetchurl {
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8637/genshingothic-20150607.zip";
    sha256 = "insert-the-correct-sha256-hash-here";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = "unzip $src";

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp *.ttf $out/share/fonts/truetype/
  '';
}
