{
  fetchurl,
  fetchFromGitHub,
  stdenv,
  cmake,
  unixODBC,
  openssl,
  libiconv,
  mariadb,
  lib,
}: {}: let
  pname = "mysql-odbc-driver";
  version = "8.1.0";
  url = "https://github.com/mysql/mysql-connector-odbc.git";
  rev = "2931780e141e741f34cb2fb6cd27f4130a19a878";
in
  stdenv.mkDerivation rec {
    inherit pname version;

    src = builtins.fetchGit {
      url = url;
      ref = "refs/tags/${version}";
      rev = rev;
      submodules = true;
    };

    nativeBuildInputs = [cmake];
    buildInputs = [unixODBC openssl libiconv mariadb];

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
      fancyName = "MySQL";
      driver = "lib/libmyodbc${stdenv.hostPlatform.extensions.sharedLibrary}";
    };

    meta = with lib; {
      description = "MySQL ODBC database driver";
      homepage = "https://github.com/mysql/mysql-connector-odbc";
      license = licenses.gpl2;
      platforms = platforms.linux ++ platforms.darwin;
    };
  }
