{ lib
, pkgs
, autoPatchelfHook
, buildFHSEnv
, qt5
, mayaRpm
}:
let
  libtiff = pkgs.callPackage ./libtiff.nix { };
  libpng15 = pkgs.callPackage ./libpng15.nix { };
in
pkgs.stdenv.mkDerivation {
  name = "maya2024.2";

  src = mayaRpm;

  nativeBuildInputs = [
    autoPatchelfHook
    pkgs.rpm
    pkgs.cpio
    qt5.wrapQtAppsHook
    pkgs.unzip
  ];

  buildInputs = [
    pkgs.audiofile
    pkgs.openssl_1_1
    pkgs.gdbm
    pkgs.cups
    pkgs.dbus
    pkgs.e2fsprogs
    pkgs.flite
    pkgs.fontconfig
    pkgs.freetype
    pkgs.gtk2
    pkgs.libcap
    pkgs.libdrm
    pkgs.liberation_ttf
    pkgs.libffi
    pkgs.libglvnd
    pkgs.xorg.libICE
    pkgs.libmng
    pkgs.libpng
    pkgs.postgresql
    pkgs.xorg.libSM
    libtiff
    pkgs.xorg.libX11
    pkgs.xorg.libXau
    pkgs.xorg.libxcb
    pkgs.xorg.libXcomposite
    pkgs.libxcrypt-legacy
    pkgs.xorg.libXcursor
    pkgs.xorg.libXdamage
    pkgs.xorg.libXext
    pkgs.xorg.libXfixes
    pkgs.xorg.libXi
    pkgs.xorg.libXinerama
    pkgs.libxkbcommon
    pkgs.xorg.libxkbfile
    pkgs.xorg.libXmu
    pkgs.xorg.libXp
    pkgs.xorg.libXpm
    pkgs.xorg.libXrandr
    pkgs.xorg.libXrender
    pkgs.xorg.libXScrnSaver
    pkgs.xorg.libxshmfence
    pkgs.xorg.libXt
    pkgs.xorg.libXtst
    pkgs.nss
    pkgs.pciutils
    pkgs.libsForQt5.full
    pkgs.xcb-util-cursor
    pkgs.xorg.xorgserver
    pkgs.zlib
    pkgs.dnf5
    pkgs.libGLU
    pkgs.libxml2
    pkgs.zstd
    pkgs.glib
    pkgs.poppler
    pkgs.gts
    # for graphviz
    pkgs.libjpeg
    pkgs.expat
    pkgs.fontconfig
    pkgs.gd
    pkgs.gts
    pkgs.pango
    pkgs.bash
    pkgs.xorg.libXaw
    pkgs.xdg-utils
    pkgs.webkitgtk_6_0
    pkgs.libsForQt5.full
    pkgs.opencl-headers
    pkgs.gtk2
    pkgs.gtk3
    libpng15
    pkgs.xorg.libXv
    pkgs.graphviz
    pkgs.poppler
    pkgs.mesa
    pkgs.ocl-icd
    pkgs.util-linux
    pkgs.steam-run
    pkgs.nspr
    pkgs.alsa-lib
    pkgs.krb5
    pkgs.attr
    pkgs.libudev0-shim
  ];

  dontUnpack = true;
  autoPatchelfIgnoreMissingDeps = true;
  # Maybe uncomment this line if at some point we have issue with Qt  
  # dontWrapQtApps = true;

  # the missing Patchelf dependencies are:
  # - libpng15.so.15
  # - libgs.so.8
  # - libpoppler-glib.so.4
  # - libgd.so.2
  # - librsvg-2.so.2

  installPhase = ''
    mkdir -p $out/unpacked
    ${pkgs.rpm}/bin/rpm2cpio $src/Maya2024_64-2024.2-1191.x86_64.rpm | ${pkgs.cpio}/bin/cpio -idmv -D $out/unpacked
    ${pkgs.rpm}/bin/rpm2cpio $src/Licensing/adlmapps29-29.0.2-0.x86_64.rpm  | ${pkgs.cpio}/bin/cpio -idmv -D $out/unpacked
    ${pkgs.rpm}/bin/rpm2cpio $src/Licensing/adskflexnetclient-11.18.0-0.x86_64.rpm  | ${pkgs.cpio}/bin/cpio -idmv -D $out/unpacked
    ${pkgs.rpm}/bin/rpm2cpio $src/Licensing/adskflexnetserverIPV6-11.18.0-0.x86_64.rpm  | ${pkgs.cpio}/bin/cpio -idmv -D $out/unpacked
    ${pkgs.rpm}/bin/rpm2cpio $src/Licensing/adsklicensing13.3.1.9694-0-0.x86_64.rpm  | ${pkgs.cpio}/bin/cpio -idmv -D $out/unpacked
    ${pkgs.rpm}/bin/rpm2cpio $src/MayaUSD2024-202310160731-bbc8cc8-0.25.0-1.x86_64.rpm  | ${pkgs.cpio}/bin/cpio -idmv -D $out/unpacked

    mv $out/unpacked/usr $out/
    mv $out/unpacked/opt $out/
    mv $out/unpacked/var $out/
    mkdir -p $out/bin

    # Arnold
    # according to unix_installer.py:
    # installDir = /usr/autodesk/arnold/maya2024
    # modulesDir = mayaBaseDir = /usr/autodesk/modules/maya/2024
    # mayaInstallDir = /usr/autodesk/maya2024
    # renderDescFolder = /usr/autodesk/maya2024/bin/rendererDesc
    # - arnold is a zip package `package.zip` and will be unzip in  installDir=/usr/autodesk/arnold/maya2024
    # - mtoa.mod need to be created in installDir=/usr/autodesk/arnold/maya2024
    # - chmod +x may be needed on all exec files
    # - mtoa.mod need to be created to /usr/autodesk/modules/maya/2024
    # - the "renderer description file" need to be put in maya dir (/usr/autodesk/maya2024/bin/rendererDesc)
    # - there are also some templates, but we probably don't care ?
    # - then it runs `LicensingUpdater` ?

    mkdir -p $out/usr/autodesk/arnold/maya2024
    ${pkgs.unzip}/bin/unzip $src/package.zip -d $out/usr/autodesk/arnold/maya2024

    cat > $out/usr/autodesk/arnold/maya2024/mtoa.mod << EOF
+ mtoa any $out/usr/autodesk/arnold/maya2024
PATH +:= bin
MAYA_CUSTOM_TEMPLATE_PATH +:= scripts/mtoa/ui/templates
MAYA_SCRIPT_PATH +:= scripts/mtoa/mel
MAYA_RENDER_DESC_PATH += $out/usr/autodesk/arnold/maya2024
MAYA_PXR_PLUGINPATH_NAME += $out/usr/autodesk/arnold/maya2024/usd
EOF

    cp $out/usr/autodesk/arnold/maya2024/mtoa.mod $out/usr/autodesk/modules/maya/2024/mtoa.mod
    cp $out/usr/autodesk/arnold/maya2024/arnoldRenderer.xml $out/usr/autodesk/maya2024/bin/rendererDesc/arnoldRenderer.xml

    # according to https://help.autodesk.com/view/MAYAUL/2024/ENU/?guid=arnold_for_maya_install_am_Installing_Arnold_for_Maya_on_Linux_html
    # Set the environment variable MAYA_MODULE_PATH to point to your /opt/solidangle/MtoA-0.24.0/2014 folder (the folder where mtoa.mod is located).https://help.autodesk.com/view/MAYAUL/2024/ENU/?guid=arnold_for_maya_install_am_Installing_Arnold_for_Maya_on_Linux_html
    # Set the environment variable MAYA_RENDER_DESC_PATH to point to your / opt/solidangle/MtoA-0.24.0 /2014 folder (the folder where arnoldRenderer.xml is located).

    # wrapper function
    make_wrapper() {
      local target="$1"
      local name="$2"
      cat > $out/bin/$name <<EOF
#!/bin/sh
export MAYA_MODULE_PATH=$out/usr/autodesk/modules/maya/2024
export MAYA_RENDER_DESC_PATH=$out/usr/autodesk/maya2024/bin/rendererDesc
export LD_LIBRARY_PATH=${pkgs.libudev0-shim}/lib:\$LD_LIBRARY_PATH
exec $target "\$@"
EOF
      chmod +x $out/bin/$name
    }

    make_wrapper "$out/usr/autodesk/maya2024/bin/maya2024" "maya2024"
    make_wrapper "$out/usr/autodesk/maya2024/bin/mayapy" "mayapy2024"
    make_wrapper "$out/opt/Autodesk/AdskLicensing/13.3.1.9694/AdskLicensingService/AdskLicensingService" "AdskLicensingService13"
    make_wrapper "$out/opt/Autodesk/AdskLicensing/13.3.1.9694/helper/AdskLicensingInstHelper" "AdskLicensingInstHelper13"
    make_wrapper "$out/usr/autodesk/arnold/maya2024/license/LicensingUpdater" "LicensingUpdater2024"

    # Replace /bin/uname with the Nix path
    substituteInPlace $out/usr/autodesk/maya2024/bin/maya2024 \
      --replace /bin/uname ${pkgs.coreutils}/bin/uname

    # remove old version of libpng16 that mess up with autopatchelf
    # Note that this may break Maya USD. Maybe.
    # Another solution would be to patchef the libpng16.so.16 of mayausd to make it more specific, and then remove the generic link
    rm $out/usr/autodesk/mayausd/maya2024/0.25.0_202310160731-bbc8cc8/mayausd/USD/lib64/libpng16.so*
    rm $out/usr/lib/.build-id/4d/8cfc47d8b42e5a893df753111604c304bbeff0
    rm $out/usr/autodesk/mayausd/maya2024/0.25.0_202310160731-bbc8cc8/mayausd/USD/lib64/libpng.so

  '';

  meta = with lib; {
    description = "Maya";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
