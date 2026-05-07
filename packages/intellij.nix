{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "intellij-idea-community";
  version = "2025.2.5";

  src = pkgs.fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIC-2025.2.5.tar.gz";
    sha256 = "995c334cc3e143f13467abafef07a1ccf7d06275512bb6f4c91123948786ab7c";
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.copyDesktopItems
  ];

  buildInputs = [
    pkgs.jetbrains.jdk
    pkgs.fontconfig
    pkgs.libX11
    pkgs.libXext
    pkgs.libXrender
    pkgs.libXtst
    pkgs.libXi
    pkgs.libXrandr
    pkgs.libXcursor
    pkgs.libXfixes
    pkgs.libxkbcommon
    pkgs.glib
    pkgs.gtk3
    pkgs.nss
    pkgs.nspr
    pkgs.cups
    pkgs.alsa-lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/intellij
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/128x128/apps
    mkdir -p $out/share/icons/hicolor/scalable/apps

    cp -r idea-IC-*/* $out/share/intellij/

    makeWrapper $out/share/intellij/bin/idea.sh $out/bin/idea \
      --set IDEA_JDK "${pkgs.jetbrains.jdk}" \
      --prefix PATH : "${pkgs.jetbrains.jdk}/bin"

    install -Dm644 \
      $out/share/intellij/bin/idea.png \
      $out/share/icons/hicolor/128x128/apps/intellij-idea-community.png

    install -Dm644 \
      $out/share/intellij/bin/idea.svg \
      $out/share/icons/hicolor/scalable/apps/intellij-idea-community.svg

    cat > $out/share/applications/intellij-idea-community.desktop <<EOF
    [Desktop Entry]
    Name=IntelliJ IDEA Community
    Comment=Capable and Ergonomic IDE for JVM
    Exec=idea
    Icon=intellij-idea-community
    Terminal=false
    Type=Application
    Categories=Development;IDE;Java;
    StartupWMClass=jetbrains-idea
    EOF

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "IntelliJ IDEA Community Edition";
    homepage = "https://www.jetbrains.com/idea/";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "idea";
  };
}
