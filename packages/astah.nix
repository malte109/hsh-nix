{ lib
, stdenv
, makeWrapper
, jdk21
, dpkg
, copyDesktopItems
, makeDesktopItem
, imagemagick
}:

stdenv.mkDerivation rec {
  pname = "astah-professional";
  version = "10.1.0";

src = builtins.fetchurl {
    name = "astah-professional_10.1.0.9ceee1-0_all.deb";
    url = "https://members.change-vision.com/old/files/_nowfI-4ns64dNUSWncYybiIdoqL7x7aK/astah_professional/10_1_0/astah-professional_10.1.0.9ceee1-0_all.deb;jsessionid=E0E1D4CCA8660F282CF87438E78144C1";
    sha256 = "9b8e9cbfb7a1b989bbc009e3f90955cf8388c821fd655ecb91875d8c9da1acfb";
  };
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    dpkg
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    jdk21
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "astah-professional";
      exec = "astah-pro";
      icon = "astah-professional";
      desktopName = "Astah Professional";
      comment = "UML and modeling tool";
      categories = [ "Development" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p deb-contents
    dpkg-deb -x "$src" deb-contents

    mkdir -p $out/bin
    mkdir -p $out/share/astah_professional
    mkdir -p $out/share/icons/hicolor/64x64/apps

    cp -r deb-contents/usr/lib/astah_professional/. $out/share/astah_professional/

    if [ -f deb-contents/usr/share/pixmaps/astah_professional.png ]; then
      cp deb-contents/usr/share/pixmaps/astah_professional.png \
        $out/share/icons/hicolor/64x64/apps/astah-professional.png
    fi

    makeWrapper ${jdk21}/bin/java $out/bin/astah-pro \
      --add-flags "-jar $out/share/astah_professional/astah-pro.jar" \
      --add-flags "-Xmx1024m" \
      --add-flags "-Dastah.home=$out/share/astah_professional" \
      --set JAVA_HOME "${jdk21}" \
      --set PATH "${jdk21}/bin:$PATH"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Astah Professional – UML modeling tool";
    homepage = "https://astah.net";
    license = licenses.unfree;
    maintainers = [];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
