{
  description = "Nix flake for ODBC drivers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      # use old version of nix packages that builds against glibc 2.35
      pkgs =
        import (builtins.fetchGit {
          name = "nixpkgs-with-glibc-2.35-224";
          url = "https://github.com/nixos/nixpkgs";
          ref = "refs/heads/nixpkgs-unstable";
          rev = "8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8";
        }) {
          inherit system;
          overlays = [self.overlay];
        };
    in {
      # packages exported by the flake
      packages = {
        db2-odbc-driver = pkgs.db2-odbc-driver {};
        mssql-odbc-driver = pkgs.mssql-odbc-driver {};
        oracle-odbc-driver = pkgs.oracle-odbc-driver {};
        postgres-odbc-driver = pkgs.postgres-odbc-driver {};
        mysql-odbc-driver = pkgs.mysql-odbc-driver {};
        mariadb-odbc-driver = pkgs.mariadb-odbc-driver {};
        snowflake-odbc-driver = pkgs.snowflake-odbc-driver {};
        big-query-odbc-driver = pkgs.big-query-odbc-driver {};
        mongo-db-odbc-driver = pkgs.mongo-db-odbc-driver {};
        default = pkgs.postgres-odbc-driver {};
      };

      # nix fmt
      formatter = pkgs.alejandra;
    });
  in
    outputs
    // {
      # Overlay that can be imported so you can access the packages
      # using odbc-drivers-nix.overlay
      overlay = final: prev: {
        db2-odbc-driver = prev.pkgs.callPackage ./packages/db2.nix {};
        mssql-odbc-driver = prev.pkgs.callPackage ./packages/mssql.nix {};
        oracle-odbc-driver = prev.pkgs.callPackage ./packages/oracle.nix {};
        postgres-odbc-driver = prev.pkgs.callPackage ./packages/postgres.nix {};
        mysql-odbc-driver = prev.pkgs.callPackage ./packages/mysql.nix {};
        mariadb-odbc-driver = prev.pkgs.callPackage ./packages/mariadb.nix {};
        snowflake-odbc-driver = prev.pkgs.callPackage ./packages/snowflake.nix {};
        big-query-odbc-driver = prev.pkgs.callPackage ./packages/big-query.nix {};
        mongo-db-odbc-driver = prev.pkgs.callPackage ./packages/mongo-db.nix {};
      };
    };
}
