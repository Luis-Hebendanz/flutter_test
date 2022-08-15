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
          gtk3-x11
          pcre
          libepoxy
          lzlib
          clang
        ];
      in
      {
        defaultPackage = luis.flutter.mkFlutterApp {
          pname = "my_app3";
          version = "0.0.1";
          vendorHash = "sha256-HnZqtVTUJ9mQIRHCKCPrvRnqaHnYh+FELiF/pMKeCyQ=";
          src = ./my_app3;
        };

        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        devShell = with pkgs; mkShell {
          nativeBuildInputs = nativeDeps ++ [ chromium ];
          buildInputs = buildDeps;
          LD_LIBRARY_PATH = "${libepoxy}/lib";
          PUB_CACHE = "./.pub-cache";
          CHROME_EXECUTABLE = "chromium";
        };
      });
}
