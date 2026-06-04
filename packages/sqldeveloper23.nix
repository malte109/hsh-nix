{ pkgs ? import <nixpkgs> {} }:

let
  jdk = pkgs.jdk11;
in
pkgs.stdenv.mkDerivation rec {
  pname = "sqldeveloper";
  version = "23.1.1.345.2114";

  src = pkgs.fetchurl {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-23.1.1.345.2114-no-jre.zip";
    sha256 = "ae84622086392ab29d235aa5c9cadfef976f5b1453a0c301a007f74c005d92e5";
  };

  nativeBuildInputs = [ pkgs.unzip pkgs.makeWrapper pkgs.copyDesktopItems ];
  buildInputs = [ jdk ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "sqldeveloper";
      exec = "sqldeveloper";
      icon = "sqldeveloper";
      desktopName = "Oracle SQL Developer";
      comment = "Oracle SQL Developer 23.1";
      categories = [ "Development" "Database" ];
    })
  ];

  unpackPhase = ''
    unzip -q $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sqldeveloper
    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/48x48/apps

    cp -r sqldeveloper/. $out/share/sqldeveloper/

    # Icon liegt direkt im ZIP-Archiv unter sqldeveloper/icon.png
    if [ -f $out/share/sqldeveloper/icon.png ]; then
      install -Dm644 $out/share/sqldeveloper/icon.png \
        $out/share/icons/hicolor/48x48/apps/sqldeveloper.png
    fi

    makeWrapper $out/share/sqldeveloper/sqldeveloper.sh $out/bin/sqldeveloper \
      --chdir $out/share/sqldeveloper \
      --set JAVA_HOME ${jdk} \
      --set PATH "${jdk}/bin:$out/bin:/usr/bin"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Oracle SQL Developer 23.1";
    homepage = "https://www.oracle.com/database/technologies/appdev/sqldeveloper-landing.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sqldeveloper";
  };
}
