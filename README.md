# odbc-drivers-nix

Nix flake for ODBC drivers

## Usage

This `odbc-drivers-nix` flake assumes you have already [installed nix](https://determinate.systems/posts/determinate-nix-installer)

### Add the `odbc-drivers-nix` overlay to your own flake

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.odbc-drivers.url = "github:rupurt/odbc-drivers-nix";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    odbc-drivers,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            odbc-drivers.overlay
          ];
        };
      in rec
      {
        packages = {
          db2-odbc-driver = pkgs.db2-odbc-driver {};
          mssql-odbc-driver = pkgs.mssql-odbc-driver {};
          oracle-odbc-driver = pkgs.oracle-odbc-driver {};
          postgres-odbc-driver = pkgs.postgres-odbc-driver {};
          mysql-odbc-driver = pkgs.mysql-odbc-driver {};
          maria-db-odbc-driver = pkgs.maria-db-odbc-driver {};
          snowflake-odbc-driver = pkgs.snowflake-odbc-driver {};
          big-query-odbc-driver = pkgs.big-query-odbc-driver {};
          mongo-db-odbc-driver = pkgs.mongo-db-odbc-driver {};
        };

        devShells.default = pkgs.mkShell {
          packages = [
            packages.db2-odbc-driver
            packages.mssql-odbc-driver
            packages.oracle-odbc-driver
            packages.postgres-odbc-driver
            packages.mysql-odbc-driver
            packages.maria-db-odbc-driver
            packages.snowflake-odbc-driver
            packages.big-query-odbc-driver
            packages.mongo-db-odbc-driver
          ];
        };
      }
    );
}
```

The above configuration will add a [nix overlay](https://nixos.wiki/wiki/Overlays) to the
packages in your flake which will allow you to reference the individual driver packages
required for your project.

## Supported ODBC Drivers

| Database                                                                                        | Version    | Linux x86_64 | Linux arm64 | OS X x86_64 | OS X aarch64 |
| ----------------------------------------------------------------------------------------------- | :--------: | :----------: | :---------: | :---------: | :----------: |
| [Db2](https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli)           | v11.5.8    | `[x]`        | `[ ]`       | `[ ]`       | `[ ]`        |
| [MSSQL](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server) | 18.2.2.1   | `[ ]`        | `[ ]`       | `[ ]`       | `[ ]`        |
| [Oracle](https://www.oracle.com/database/technologies/instant-client/downloads.html)            | x.x.x      | `[ ]`        | `[ ]`       | `[ ]`       | `[ ]`        |
| [Postgres](https://www.postgresql.org/download)                                                 | x.x.x      | `[x]`        | `[x]`       | `[ ]`       | `[ ]`        |
| [MySQL](https://dev.mysql.com/downloads/connector/odbc)                                         | x.x.x      | `[ ]`        | `[ ]`       | `[ ]`       | `[ ]`        |
| [MariaDB](https://mariadb.com/kb/en/mariadb-connector-odbc)                                     | x.x.x      | `[ ]`        | `[ ]`       | `[ ]`       | `[ ]`        |
| [Snowflake](https://developers.snowflake.com/odbc)                                              | x.x.x      | `[ ]`        | `[ ]`       | `[ ]`       | `[ ]`        |
| [BigQuery](https://cloud.google.com/bigquery/docs/reference/odbc-jdbc-drivers)                  | 3.0.0.1001 | `[ ]`        | `[ ]`       | `[ ]`       | `[ ]`        |
| [MongoDB](https://www.mongodb.com/docs/bi-connector/master/reference/odbc-driver)               | x.x.x      | `[ ]`        | `[ ]`       | `[ ]`       | `[ ]`        |

## Authors

- Alex Kwiatkowski - alex+git@fremantle.io

## License

`odbc-drivers-nix` is released under the MIT license
