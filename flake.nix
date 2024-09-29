{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: let
    inherit (nixpkgs.lib) genAttrs mapAttrs systems;

    fonts = {
      sf-pro = {
        dmg = "SF-Pro.dmg";
        hash = "sha256-IccB0uWWfPCidHYX6sAusuEZX906dVYo8IaqeX7/O88";
      };
      sf-compact = {
        dmg = "SF-Compact.dmg";
        hash = "sha256-PlraM6SwH8sTxnVBo6Lqt9B6tAZDC//VCPwr/PNcnlk";
      };
      sf-mono = {
        dmg = "SF-Mono.dmg";
        hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU";
      };
      sf-arabic = {
        dmg = "SF-Arabic.dmg";
        hash = "sha256-J2DGLVArdwEsSVF8LqOS7C1MZH/gYJhckn30jRBRl7k";
      };
      ny = {
        dmg = "NY.dmg";
        hash = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ";
      };
    };
  in {
    packages = genAttrs systems.flakeExposed (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      makeAppleFont = name: font: pkgs.stdenvNoCC.mkDerivation {
        inherit name;

        src = pkgs.fetchurl {
          url = "https://devimages-cdn.apple.com/design/resources/download/${font.dmg}";
          hash = font.hash;
        };

        nativeBuildInputs = with pkgs; [
          undmg
          p7zip
        ];

        unpackPhase = ''
          undmg $src
          7z x *.pkg
          7z x 'Payload~'
        '';

        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          mkdir -p $out/share/fonts/truetype
          find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
          find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
        '';
      };
    in
      mapAttrs makeAppleFont fonts);
  };
}
