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
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          odbc-drivers.overlay
        ];
      };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.odbc-driver-pkgs.db2-odbc-driver
            pkgs.odbc-driver-pkgs.postgres-odbc-driver
            pkgs.odbc-driver-pkgs.mariadb-odbc-driver
          ];
        };
      };
    );
}
```

The above configuration will add a [nix overlay](https://nixos.wiki/wiki/Overlays) to the
packages in your flake which will allow you to reference the individual driver packages
required for your project.

## Supported ODBC Drivers

| Database                                                                                        | Version    | Linux x86_64 | Linux arm64 | OS X x86_64 | OS X aarch64 |
| ----------------------------------------------------------------------------------------------- | :--------: | :----------: | :---------: | :---------: | :----------: |
| [Db2](https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli)           | v11.5.9    | `[x]`        | `[ ]`       | `[x]`       | `[ ]`        |
| [Postgres](https://www.postgresql.org/download)                                                 | 15.00.0000 | `[x]`        | `[x]`       | `[x]`       | `[x]`        |
| [MariaDB](https://mariadb.com/kb/en/mariadb-connector-odbc)                                     | 3.1.9      | `[x]`        | `[x]`       | `[x]`       | `[x]`        |

## Authors

- Alex Kwiatkowski - alex+git@fremantle.io

## License

`odbc-drivers-nix` is released under the MIT license
