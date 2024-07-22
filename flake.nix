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
        hash = "sha256-B8xljBAqOoRFXvSOkOKDDWeYUebtMmQLJ8lF05iFnXk=";
      };
      sf-compact = {
        name = "sf-compact";
        dmg = "SF-Compact.dmg";
        hash = "sha256-L4oLQ34Epw1/wLehU9sXQwUe/LaeKjHRxQAF6u2pfTo=";
      };
      sf-mono = {
        name = "sf-mono";
        dmg = "SF-Mono.dmg";
        hash = "sha256-Uarx1TKO7g5yVBXAx6Yki065rz/wRuYiHPzzi6cTTl8=";
      };
      sf-arabic = {
        name = "sf-arabic";
        dmg = "SF-Arabic.dmg";
        hash = "sha256-1clBp+aePSLNR9JrS+jReH7pEJtsH+zpzsiBKLQvvUs=";
      };
      ny = {
        name = "ny";
        dmg = "NY.dmg";
        hash = "sha256-yYyqkox2x9nQ842laXCqA3UwOpUGyIfUuprX975OsLA=";
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
