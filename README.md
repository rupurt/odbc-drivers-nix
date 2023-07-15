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
      # use old version of nix packages that builds against glibc 2.35
      pkgs =
        import (builtins.fetchGit {
          name = "nixpkgs-with-glibc-2.35-224";
          url = "https://github.com/nixos/nixpkgs";
          ref = "refs/heads/nixpkgs-unstable";
          rev = "8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8";
        }) {
          inherit system;
          overlays = [
            odbc-drivers.overlay
          ];
        };
      stdenv = pkgs.gccStdenv;
    in rec {
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
        };

        devShells.default = pkgs.mkShell {
          packages = [
            packages.db2-odbc-driver
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
| [Db2](https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli)           | v11.5.8    | `[x]`        | `[ ]`       | `[x]`       | `[ ]`        |

## Authors

- Alex Kwiatkowski - alex+git@fremantle.io

## License

`odbc-drivers-nix` is released under the MIT license
