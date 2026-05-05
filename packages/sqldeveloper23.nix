{ pkgs ? import <nixpkgs> {} }:

let
  jdk = pkgs.jdk11;
in
pkgs.stdenv.mkDerivation rec {
  pname = "sqldeveloper";
  version = "23.1.1.345.2114";

  # Oracle requires accepting a license – fetchurl works here because
  # the otn_software subdomain does not enforce a cookie gate for this zip.
  src = pkgs.fetchurl {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-23.1.1.345.2114-no-jre.zip";
    sha256 = "ae84622086392ab29d235aa5c9cadfef976f5b1453a0c301a007f74c005d92e5";
  };

  nativeBuildInputs = [ pkgs.unzip pkgs.makeWrapper ];
  buildInputs = [ jdk ];

  unpackPhase = ''
    unzip -q $src
  '';

  installPhase = ''
    mkdir -p $out/share/sqldeveloper
    mkdir -p $out/bin

    cp -r sqldeveloper/. $out/share/sqldeveloper/

    # sqldeveloper.sh uses relative paths and must be called from its
    # own directory – same technique as the Flatpak wrapper.
    makeWrapper $out/share/sqldeveloper/sqldeveloper.sh $out/bin/sqldeveloper \
      --chdir $out/share/sqldeveloper \
      --set JAVA_HOME ${jdk} \
      --set PATH "${jdk}/bin:$out/bin:/usr/bin"
  '';

  meta = with pkgs.lib; {
    description = "Oracle SQL Developer 23.1";
    homepage = "https://www.oracle.com/database/technologies/appdev/sqldeveloper-landing.html";
    # Oracle Technology Network License – non-free
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sqldeveloper";
  };
}
