{
  stdenv,
  pkgs,
}: {}: let
  pname = "mysql-odbc-driver";
  version = "8.0.33";
  rev = "913f45590844a5c26f376a0ec48889eac7c72c26";

in
  stdenv.mkDerivation {
    inherit pname version;
    src = builtins.fetchGit {
      url = "https://github.com/mysql/mysql-connector-odbc.git";
      ref = "refs/tags/${version}";
      rev = rev;
    };

    nativeBuildInputs = [
      pkgs.cmake
    ];

    buildInputs = [
      # pkgs.mysql
      # can't follow symlink to mysql.h
      # - need nixpkgs to update to 3.3
      pkgs.libmysqlclient
      # pkgs.mariadb
      pkgs.unixODBC
    ];

    installPhase = ''
      mkdir -p $out/lib
      cp -r lib/* $out/lib
    '';
  }
