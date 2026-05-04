{
  description = "Hochschul-Paketsammlung";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "astah-professional"
            "sqldeveloper"
          ];
      };
    in
    {
      packages = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          greenfoot     = pkgs.callPackage ./packages/greenfoot.nix { };
          jedit         = pkgs.callPackage ./packages/jedit.nix { };
          netbeans      = pkgs.callPackage ./packages/netbeans.nix { };
          astah         = pkgs.callPackage ./packages/astah/astah.nix { };
          sqldeveloper  = pkgs.callPackage ./packages/sqldeveloper.nix { };
          intellij-idea = pkgs.jetbrains.idea-oss;
        });
      apps = forAllSystems (system: {
        intellij-idea = {
          type = "app";
          program = "${pkgsFor system}.jetbrains.idea-oss}/bin/idea-oss";
        };
        astah = {
          type = "app";
          program = "${self.packages.${system}.astah}/bin/astah-pro";
        };
      });
    };
}
