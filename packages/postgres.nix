{
  pkgs,
  specialArgs ? {},
}: let
  defaultArgs = {
    pname = "postgres-odbc-driver";
    version = "16.00.0000";
    sha256 = "sha256-r9iS+J0uzujT87IxTxvVvy0CIBhyxuNDHlwxCW7KTIs=";
  };
  args = defaultArgs // specialArgs;
in
  pkgs.stdenv.mkDerivation {
    pname = args.pname;
    version = args.version;
    src = pkgs.fetchurl {
      url = "https://ftp.postgresql.org/pub/odbc/versions.old/src/psqlodbc-${args.version}.tar.gz";
      sha256 = args.sha256;
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
