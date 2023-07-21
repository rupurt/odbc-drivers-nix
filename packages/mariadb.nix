{
  fetchurl,
  fetchFromGitHub,
  stdenv,
  cmake,
  unixODBC,
  openssl,
  libiconv,
  lib,
}: {}: let
  pname = "mariadb-odbc-driver";
  version = "3.1.9";
  sha256 = "0wvy6m9qfvjii3kanf2d1rhfaww32kg0d7m57643f79qb05gd6vg";
in
  stdenv.mkDerivation rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "mariadb-corporation";
      repo = "mariadb-connector-odbc";
      rev = version;
      sha256 = sha256;
      # this driver only seems to build correctly when built against the mariadb-connect-c subrepo
      # (see https://github.com/NixOS/nixpkgs/issues/73258)
      fetchSubmodules = true;
    };

    nativeBuildInputs = [cmake];
    buildInputs = [unixODBC openssl libiconv];

    preConfigure = ''
      # we don't want to build a .pkg
      substituteInPlace CMakeLists.txt \
        --replace "IF(APPLE)" "IF(0)" \
        --replace "CMAKE_SYSTEM_NAME MATCHES AIX" "APPLE"
    '';

    cmakeFlags = [
      "-DODBC_LIB_DIR=${lib.getLib unixODBC}/lib"
      "-DODBC_INCLUDE_DIR=${lib.getDev unixODBC}/include"
      "-DWITH_OPENSSL=ON"
      # on darwin this defaults to ON but we want to build against unixODBC
      "-DWITH_IODBC=OFF"
    ];

    passthru = {
      fancyName = "MariaDB";
      driver = "lib/libmaodbc${stdenv.hostPlatform.extensions.sharedLibrary}";
    };

    meta = with lib; {
      description = "MariaDB ODBC database driver";
      homepage = "https://downloads.mariadb.org/connector-odbc/";
      license = licenses.gpl2;
      platforms = platforms.linux ++ platforms.darwin;
    };
  }
