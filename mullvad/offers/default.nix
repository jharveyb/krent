with (import <nixpkgs> {}).pkgs;
with lib;

let
  myPyPkgs = python38Packages.override {
    overrides = self: super: {
      pylightning = super.buildPythonPackage rec {
        pname = "pylightning";
        version = "0.0.7.3";
        src = super.fetchPypi {
          inherit pname version;
          # sha256 = "1qrbk8v2bxm8k6knx33vajajs8y2lsn77j4byviy7mh354xwzsc4";
          sha256 = "age2KyfgG6r1EWXi37i30dR/Ya74MEqdo8pQgWCKMsA=";
        };
        buildInputs = with super;
          [  ];
      };
    };
  };
in
stdenv.mkDerivation rec {
  name = "krent";
  buildInputs = (with myPyPkgs;
    [
      pylightning
    ]);
  src = null;

}
