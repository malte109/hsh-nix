{ pkgs ? import <nixpkgs> {} }:

let
  jdk = pkgs.jdk21;
in
pkgs.stdenv.mkDerivation rec {
  pname = "jedit";
  version = "5.7.0";

  src = pkgs.fetchurl {
    url = "https://sourceforge.net/projects/jedit/files/jedit/5.7.0/jedit_5.7.0_all.deb/download";
    name = "jedit_5.7.0_all.deb";
    sha256 = "18494fb595846404f4181009dc7a4fa1af21bd07c049a5dd5ef4cb7e37c160c6";
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.makeWrapper pkgs.copyDesktopItems ];
  buildInputs = [ jdk ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "jedit";
      exec = "jedit";
      icon = "jedit";
      desktopName = "jEdit";
      comment = "Programmer's text editor written in Java";
      categories = [ "Development" "TextEditor" ];
    })
  ];

  unpackPhase = ''
    dpkg-deb -x $src deb-contents
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jEdit
    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/48x48/apps

    cp -r deb-contents/usr/share/jEdit/. $out/share/jEdit/

    # Icon aus dem deb übernehmen
    if [ -f deb-contents/usr/share/pixmaps/jedit.png ]; then
      install -Dm644 deb-contents/usr/share/pixmaps/jedit.png \
        $out/share/icons/hicolor/48x48/apps/jedit.png
    fi

    makeWrapper ${jdk}/bin/java $out/bin/jedit \
      --add-flags "-jar $out/share/jEdit/jedit.jar" \
      --set JAVA_HOME ${jdk}

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Programmer's text editor written in Java";
    homepage = "https://www.jedit.org/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    mainProgram = "jedit";
  };
}
