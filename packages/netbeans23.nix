{ pkgs ? import <nixpkgs> {} }:

let
  jdk = pkgs.jdk21;
in
pkgs.stdenv.mkDerivation rec {
  pname = "netbeans";
  version = "23";

  src = pkgs.fetchurl {
    url = "https://archive.apache.org/dist/netbeans/netbeans-installers/23/apache-netbeans_23-1_all.deb";
    sha256 = "01e8318753d8d25840467998357559be98fe9ddfcfc0581c7eaa327c869ce2c7";
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.makeWrapper pkgs.copyDesktopItems ];
  buildInputs = [ jdk ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "netbeans";
      exec = "netbeans";
      icon = "apache-netbeans";
      desktopName = "Apache NetBeans";
      comment = "Apache NetBeans IDE";
      categories = [ "Development" "IDE" "Java" ];
    })
  ];

  unpackPhase = ''
    dpkg-deb -x $src deb-contents
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mkdir -p $out/bin

    cp -r deb-contents/usr/lib/apache-netbeans $out/lib/apache-netbeans

    # Icon aus dem deb übernehmen
    if [ -f deb-contents/usr/share/icons/hicolor/48x48/apps/apache-netbeans.png ]; then
      install -Dm644 deb-contents/usr/share/icons/hicolor/48x48/apps/apache-netbeans.png \
        $out/share/icons/hicolor/48x48/apps/apache-netbeans.png
    elif [ -f deb-contents/usr/share/pixmaps/apache-netbeans.png ]; then
      install -Dm644 deb-contents/usr/share/pixmaps/apache-netbeans.png \
        $out/share/icons/hicolor/48x48/apps/apache-netbeans.png
    fi

    substituteInPlace $out/lib/apache-netbeans/bin/netbeans \
      --replace '/usr/lib/jvm/java-21-openjdk-amd64' '${jdk}' || true

    makeWrapper $out/lib/apache-netbeans/bin/netbeans $out/bin/netbeans \
      --add-flags "--jdkhome ${jdk}" \
      --add-flags "--userdir \''${XDG_CONFIG_HOME:-\$HOME/.config}/netbeans/23" \
      --set JAVA_HOME ${jdk} \
      --set PATH "${jdk}/bin:$out/bin:/usr/bin"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Apache NetBeans IDE 23";
    homepage = "https://netbeans.apache.org/";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "netbeans";
  };
}
