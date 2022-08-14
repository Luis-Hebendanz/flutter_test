{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    luispkgs.url = "github:Luis-Hebendanz/nixpkgs/luispkgs";
  };

  outputs = { self, nixpkgs, utils, naersk, luispkgs }:
    utils.lib.eachDefaultSystem (system:
      let
        luis = import luispkgs { inherit system; };
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
        deps = with pkgs; [ chromium at-spi2-core dbus libxkbcommon xorg.libXdmcp libdatrie libthai libsepol libselinux util-linux wxGTK31 gtk3 gtk3-x11 pcre libepoxy ninja lzlib cmake clang cargo rustc rustfmt pre-commit rustPackages.clippy luis.flutter ];
      in
      {
        defaultPackage = with pkgs; stdenv.mkDerivation {
          src = ./.;
          name = "test";
          buildInputs = deps;
          nativeBuildInputs = [ pkg-config ];
          buildPhase = ''

          '';
          installPhase = ''
          '';
        };

        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        devShell = with pkgs; mkShell {
          nativeBuildInputs = [ pkg-config ];
          buildInputs = deps;
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          hardeningDisable = [ "all" ];
          LD_LIBRARY_PATH = "${libepoxy}/lib";
	        CHROME_EXECUTABLE = "chromium";
        };
      });
}
