{
  description = "Hochschul-Paketsammlung";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          greenfoot = pkgs.callPackage ./packages/greenfoot.nix { };
          jedit = pkgs.callPackage ./packages/jedit.nix { };
          netbeans = pkgs.callPackage ./packages/netbeans.nix { };

          intellij-idea = pkgs.jetbrains.idea-oss;
        });

      apps = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          intellij-idea = {
            type = "app";
            program = "${pkgs.jetbrains.idea-oss}/bin/idea-oss";
          };
        });
    };
}
