{
  autoPatchelfHook,
  fetchurl,
  glibc,
  lib,
  libxml2,
  pam,
  libxcrypt,
  libxcrypt-legacy,
  stdenv,
}: {}: let
  pname = "db2-odbc-driver";
  version = "11.5.8";
  sources = {
    aarch64-darwin = fetch "macos64" "sha256-xkezCidWDRM0mBqiXJGLsh0lMubO9YzVhbYmeV/cHRU=";
    x86_64-darwin = fetch "macos64" "sha256-xkezCidWDRM0mBqiXJGLsh0lMubO9YzVhbYmeV/cHRU=";
    x86_64-linux = fetch "linuxx64" "sha256-P3aQJNzBCJO2SNxYjnDwzckHi7zp6xzIc7qm4Qb703w=";
  };
  fetch = platform: sha256:
    fetchurl {
      inherit sha256;
      url = "https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/v${version}/${platform}_odbc_cli.tar.gz";
    };
in
  stdenv.mkDerivation {
    inherit pname version;
    src = sources.${stdenv.hostPlatform.system};

    nativeBuildInputs = lib.optional stdenv.isLinux [
      autoPatchelfHook
    ];

    buildInputs =
      [
        libxml2
        pam
        stdenv.cc.cc.lib
      ]
      # when using glibc >= 2.36 on linux need libxcrypt-legacy for libcrypt.so
      # https://github.com/NixOS/nixpkgs/issues/223805
      ++ lib.optionals (stdenv.isLinux) [
        libxcrypt-legacy
      ]
      ++ lib.optionals (stdenv.isDarwin) [
        libxcrypt
      ];

    installPhase = ''
      mkdir -p $out/lib
      cp -r lib/* $out/lib
    '';
  }
