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

  # Lokale .deb-Datei als Quelle – sha256 mit `sha256sum <datei>.deb` ermitteln
  src = ./astah-professional_10.1.0.9ceee1-0_all.deb;

  # Kein normaler Quellbaum, daher unpack selbst übernehmen
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

    # .deb entpacken
    mkdir -p deb-contents
    dpkg-deb -x "$src" deb-contents

    # Verzeichnisse anlegen
    mkdir -p $out/bin
    mkdir -p $out/share/astah_professional
    
    # Programmdateien kopieren
    cp -r deb-contents/usr/lib/astah_professional/. $out/share/astah_professional/

    # Icon kopieren
    if [ -f deb-contents/usr/share/pixmaps/astah_professional.png ]; then
      install -Dm644 deb-contents/usr/share/pixmaps/astah_professional.png \
        $out/share/icons/hicolor/64x64/apps/astah-professional.png
    fi

    # Wrapper-Skript erstellen – löst das hardcoded-Pfade-Problem
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
