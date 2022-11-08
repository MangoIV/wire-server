# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation
, aeson
, base
, conduit
, containers
, cql
, cql-io
, cql-io-tinylog
, exceptions
, gitignoreSource
, imports
, lens
, lens-aeson
, lib
, optparse-applicative
, retry
, split
, text
, time
, tinylog
, uuid
, wreq
}:
mkDerivation {
  pname = "cassandra-util";
  version = "0.16.5";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson
    base
    conduit
    containers
    cql
    cql-io
    cql-io-tinylog
    exceptions
    imports
    lens
    lens-aeson
    optparse-applicative
    retry
    split
    text
    time
    tinylog
    uuid
    wreq
  ];
  description = "Cassandra Utilities";
  license = lib.licenses.agpl3Only;
}
