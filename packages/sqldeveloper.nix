{ lib
, stdenv
, makeWrapper
, makeDesktopItem
, unzip
, jdk11
}:

stdenv.mkDerivation rec {
  pname = "sqldeveloper";
  version = "23.1.1.345.2114";

  src = builtins.fetchurl {
    name = "sqldeveloper-${version}-no-jre.zip";
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-23.1.1.345.2114-no-jre.zip";
    sha256 = "ae84622086392ab29d235aa5c9cadfef976f5b1453a0c301a007f74c005d92e5";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "sqldeveloper";
      exec = "sqldeveloper";
      icon = "sqldeveloper";
      desktopName = "Oracle SQL Developer";
      comment = "Oracle DB GUI client";
      categories = [ "Development" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    unzip "$src" -d unpacked

    mkdir -p $out/bin
    mkdir -p $out/libexec
    mkdir -p $out/share/icons/hicolor/64x64/apps

    cp -r unpacked/sqldeveloper/. $out/libexec/

    if [ -f $out/libexec/icon.png ]; then
      cp $out/libexec/icon.png $out/share/icons/hicolor/64x64/apps/sqldeveloper.png
    fi

    makeWrapper $out/libexec/sqldeveloper.sh $out/bin/sqldeveloper \
      --set JAVA_HOME "${jdk11}" \
      --set PATH "${jdk11}/bin:$PATH" \
      --chdir "$out/libexec"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Oracle SQL Developer – Oracle DB GUI client";
    homepage = "https://www.oracle.com/database/sqldeveloper/";
    license = licenses.unfree;
    maintainers = [];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
