# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation
, aeson
, attoparsec
, base
, bytestring
, bytestring-conversion
, cassandra-util
, containers
, deriving-swagger2
, gitignoreSource
, imports
, lib
, QuickCheck
, schema-profunctor
, servant-server
, servant-swagger
, string-conversions
, swagger2
, tasty
, tasty-hunit
, tasty-quickcheck
, text
, time
, tinylog
, types-common
, unordered-containers
, wire-api
}:
mkDerivation {
  pname = "brig-types";
  version = "1.35.0";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson
    attoparsec
    base
    bytestring
    bytestring-conversion
    cassandra-util
    containers
    deriving-swagger2
    imports
    QuickCheck
    schema-profunctor
    servant-server
    servant-swagger
    string-conversions
    swagger2
    text
    time
    tinylog
    types-common
    unordered-containers
    wire-api
  ];
  testHaskellDepends = [
    aeson
    attoparsec
    base
    bytestring
    bytestring-conversion
    containers
    imports
    QuickCheck
    swagger2
    tasty
    tasty-hunit
    tasty-quickcheck
    text
    time
    tinylog
    types-common
    unordered-containers
    wire-api
  ];
  description = "User Service";
  license = lib.licenses.agpl3Only;
}
