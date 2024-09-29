{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      urlBase = "https://devimages-cdn.apple.com/design/resources/download/";
      sf-pro = {
        name = "sf-pro";
        dmg = "SF-Pro.dmg";
        hash = "sha256-IccB0uWWfPCidHYX6sAusuEZX906dVYo8IaqeX7/O88";
      };
      sf-compact = {
        name = "sf-compact";
        dmg = "SF-Compact.dmg";
        hash = "sha256-PlraM6SwH8sTxnVBo6Lqt9B6tAZDC//VCPwr/PNcnlk";
      };
      sf-mono = {
        name = "sf-mono";
        dmg = "SF-Mono.dmg";
        hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU";
      };
      sf-arabic = {
        name = "sf-arabic";
        dmg = "SF-Arabic.dmg";
        hash = "sha256-J2DGLVArdwEsSVF8LqOS7C1MZH/gYJhckn30jRBRl7k";
      };
      ny = {
        name = "ny";
        dmg = "NY.dmg";
        hash = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ";
      };
      unpackPhase = dmg: ''
        ls
        echo $src
        undmg $src
        7z x *.pkg
        7z x 'Payload~'
      '';
      commonInstall = ''
        mkdir -p $out/share/fonts
        mkdir -p $out/share/fonts/opentype
        mkdir -p $out/share/fonts/truetype
      '';
      commonBuildInputs = with pkgs; [ undmg p7zip ];
      makeAppleFont = (font: pkgs.stdenvNoCC.mkDerivation {
        name = font.name;
        src = pkgs.fetchurl {
          url = "${urlBase}${font.dmg}";
          hash = font.hash;
        };

        unpackPhase = unpackPhase font.dmg;

        buildInputs = commonBuildInputs;
        setSourceRoot = "sourceRoot=`pwd`";

        installPhase = commonInstall + ''
          find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
          find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
        '';
      });
    in {
      packages = {
        sf-pro = makeAppleFont sf-pro;
        sf-compact = makeAppleFont sf-compact;
        sf-mono = makeAppleFont sf-mono;
        sf-arabic = makeAppleFont sf-arabic;
        ny = makeAppleFont ny;
      };
    }
  );
}
