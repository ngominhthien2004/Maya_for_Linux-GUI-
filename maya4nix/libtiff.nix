# file from nixos-18.09, pkgs/development/libraries/libtiff/default.nix
{ lib
, stdenv
, fetchurl

, pkg-config

, zlib
, libjpeg
, xz
}:

stdenv.mkDerivation rec {
  version = "4.0.10";
  name = "libtiff-${version}";

  src = fetchurl {
    url = "https://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    sha256 = "1r4np635gr6zlc0bic38dzvxia6iqzcrary4n1ylarzpr8fd2lic";
  };

  outputs = [ "bin" "dev" "out" "man" "doc" ];

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [ zlib libjpeg xz ]; #TODO: opengl support (bogus configure detection)

  enableParallelBuilding = true;

  doCheck = true; # not cross;

  meta = with lib; {
    description = "Library and utilities for working with the TIFF image file format";
    homepage = http://download.osgeo.org/libtiff;
    license = licenses.libtiff;
    platforms = platforms.unix;
  };
}
