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
        pkgs = import nixpkgs { inherit system; config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        }; };
        mkFlutterApp = pkgs.callPackage ./nix { flutter = luis.flutter; };
        naersk-lib = pkgs.callPackage naersk { };
        appname = "my_app3";
        nativeDeps = with pkgs; [
            autoPatchelfHook
            pkg-config
            cmake
            clang
            luis.flutter
            ninja
        ];
        buildDeps = with pkgs; [
          at-spi2-core
          dbus
          libxkbcommon
          xorg.libXdmcp
          libdatrie
          libthai
          libsepol
          libselinux
          util-linux
          wxGTK31
          gtk3
          pcre
          libepoxy
          lzlib
          clang
        ];
      in
      {
        defaultPackage = mkFlutterApp {
          pname = "my_app3";
          version = "0.0.1";
          vendorHash = "sha256-ikZbvShphzyUzJKyHInbWSfVuMujXzQM78YD8atwLCY=";
          src = ./my_app3;
        };

        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        devShell = with pkgs; mkShell {
          nativeBuildInputs = nativeDeps ++ [ chromium ];
          buildInputs = buildDeps ++ nativeDeps;
          LD_LIBRARY_PATH = "${libepoxy}/lib";
          PUB_CACHE = "./.pub-cache";
          #ANDROID_HOME="${androidenv.androidPkgs_9_0.androidsdk}/libexec/android-sdk/";
          CHROME_EXECUTABLE = "chromium";
        };
      });
}
