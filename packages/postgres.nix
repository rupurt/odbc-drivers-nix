{
  fetchurl,
  stdenv,
  pkgs,
}: {}: let
  pname = "postgres-odbc-driver";
  version = "15.00.0000";
  sha256 = "1v7qndj3gqpr2mil8hrgr9as3rdb0z0vyyz1zas7zsijjlsdcmya";
in
  stdenv.mkDerivation {
    inherit pname version;
    src = fetchurl {
      url = "https://ftp.postgresql.org/pub/odbc/versions/src/psqlodbc-${version}.tar.gz";
      sha256 = sha256;
    };

    buildInputs = [
      pkgs.unixODBC
      pkgs.postgresql
    ];

    installPhase = ''
      mkdir -p $out/lib
      cp .libs/psqlodbca.so $out/lib
      cp .libs/psqlodbcw.so $out/lib
    '';
  }
