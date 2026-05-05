{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "greenfoot";
  version = "3.9.0";

  src = pkgs.fetchurl {
    url = "https://www.greenfoot.org/download/files/Greenfoot-linux-x64-390.deb";
    sha256 = "406f0241b1fc013aaed44d2e92d8c80780c9fa2787a1f130c17fbc84849d5f49";
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.makeWrapper ];

  # Greenfoot ships its own bundled JDK inside the deb – we use that,
  # exactly as the Flatpak manifest does (JAVA_HOME=/app/share/greenfoot/jdk).
  unpackPhase = ''
    dpkg-deb -x $src deb-contents
  '';

  installPhase = ''
    mkdir -p $out/share
    mkdir -p $out/bin

    cp -r deb-contents/usr/share/greenfoot $out/share/greenfoot

    # Build the JavaFX jar list the same way the Flatpak wrapper does.
    cat > $out/bin/greenfoot << 'WRAPPER'
    #!/bin/sh
    INSTALLDIR="@out@/share/greenfoot"
    JAVAPATH="$INSTALLDIR/jdk"
    CP="$INSTALLDIR/boot.jar"
    for jar in "$INSTALLDIR"/javafx*.jar; do
      CP="$CP:$jar"
    done
    exec "$JAVAPATH/bin/java" \
      -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 \
      -Djdk.gtk.version=2 \
      -Dawt.useSystemAAFontSettings=on \
      -Xmx512M \
      -cp "$CP" bluej.Boot \
      -greenfoot=true \
      -bluej.libdir="$INSTALLDIR" \
      -bluej.compiler.showunchecked=false \
      -greenfoot.scenarios="$INSTALLDIR/../doc/Greenfoot/scenarios" \
      -greenfoot.url.javadoc="file://$INSTALLDIR/../doc/Greenfoot/API/" \
      "$@"
    WRAPPER

    substituteInPlace $out/bin/greenfoot \
      --replace '@out@' "$out"

    chmod +x $out/bin/greenfoot

    # Copy scenarios/API docs if present in the deb
    if [ -d deb-contents/usr/share/doc/Greenfoot ]; then
      mkdir -p $out/share/doc
      cp -r deb-contents/usr/share/doc/Greenfoot $out/share/doc/Greenfoot
    fi
  '';

  meta = with pkgs.lib; {
    description = "Greenfoot – interactive Java development environment";
    homepage = "https://www.greenfoot.org/";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "greenfoot";
  };
}
