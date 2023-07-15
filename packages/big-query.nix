{
  fetchurl,
  stdenv,
}: {}: let
  pname = "big-query-odbc-driver";
  version = "11.5.8";
  sources = {
    x86_64-darwin = fetch "macos64" "sha256-rd4VIbak+QUnL3MQg1jpOkP1/QJTvkTqzNlQx33Pih0=";
    x86_64-linux = fetch "linuxx64" "sha256-P3aQJNzBCJO2SNxYjnDwzckHi7zp6xzIc7qm4Qb703w=";
  };
  fetch = platform: sha256:
    fetchurl {
      inherit sha256;
      url = "https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/v${version}/${platform}_odbc_cli.tar.gz";
    };
in
  stdenv.mkDerivation {
    inherit pname version;
    src = sources.${stdenv.hostPlatform.system};

    installPhase = ''
      mkdir -p $out/lib
      cp -r lib/* $out/lib
    '';
  }
