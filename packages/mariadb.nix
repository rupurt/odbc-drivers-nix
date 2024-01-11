{
  pkgs,
  specialArgs ? {},
}: let
  defaultArgs = {
    pname = "mariadb-odbc-driver";
    version = "3.1.14";
    sha256 = "0wvy6m9qfvjii3kanf2d1rhfaww32kg0d7m57643f79qb05gd6vg";
  };
  args = defaultArgs // specialArgs;
in
  pkgs.stdenv.mkDerivation {
    pname = args.pname;
    version = args.version;

    src = pkgs.fetchFromGitHub {
      owner = "mariadb-corporation";
      repo = "mariadb-connector-odbc";
      rev = args.version;
      sha256 = args.sha256;
      # this driver only seems to build correctly when built against the mariadb-connect-c subrepo
      # (see https://github.com/NixOS/nixpkgs/issues/73258)
      fetchSubmodules = true;
    };

    nativeBuildInputs = [pkgs.cmake];
    buildInputs =
      [pkgs.unixODBC pkgs.openssl pkgs.libiconv pkgs.zlib]
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [pkgs.libkrb5];

    preConfigure = ''
      # we don't want to build a .pkg
      substituteInPlace CMakeLists.txt \
        --replace "IF(APPLE)" "IF(0)" \
        --replace "CMAKE_SYSTEM_NAME MATCHES AIX" "APPLE"
    '';

    cmakeFlags = [
      "-DWITH_IODBC=OFF"
      "-DWITH_EXTERNAL_ZLIB=ON"
      "-DODBC_LIB_DIR=${pkgs.lib.getLib pkgs.unixODBC}/lib"
      "-DODBC_INCLUDE_DIR=${pkgs.lib.getDev pkgs.unixODBC}/include"
      "-DWITH_OPENSSL=ON"
      # on darwin this defaults to ON but we want to build against unixODBC
      "-DWITH_IODBC=OFF"
    ];

    passthru = {
      fancyName = "MariaDB";
      driver = "lib/libmaodbc${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
    };

    meta = with pkgs.lib; {
      description = "MariaDB ODBC database driver";
      homepage = "https://downloads.mariadb.org/connector-odbc/";
      license = licenses.gpl2;
      platforms = platforms.linux ++ platforms.darwin;
    };
  }
