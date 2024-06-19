{
  description = "Plover flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.utils.url = "github:numtide/flake-utils";
  inputs.plover = {
    url = "github:openstenoproject/plover/v4.0.0rc2";
    flake = false;
  };
  inputs.plover_stroke = {
    url = "github:openstenoproject/plover_stroke/1.1.0";
    flake = false;
  };
  inputs.rtf_tokenize = {
    url = "github:openstenoproject/rtf_tokenize/1.0.0";
    flake = false;
  };

  outputs = { nixpkgs, utils, ... }@inputs: 
    utils.lib.eachDefaultSystem (system: 
      let 
        pkgs = import nixpkgs { inherit system; };
        rtf_tokenize = with pkgs.python3Packages; buildPythonPackage {
          name = "plover_stroke";
          src = inputs.plover_stroke;
        };
        plover_stroke = with pkgs.python3Packages; buildPythonPackage {
          name = "rtf_tokenize";
          src = inputs.rtf_tokenize;
        };
        plover = with pkgs.python3Packages; pkgs.qt5.mkDerivationWith buildPythonPackage {
          name = "plover";
          version = "4.0.0rc2";

          src = inputs.plover;

          doCheck = false;

          propagatedBuildInputs = with pkgs; [
            babel pyqt5 xlib pyserial
            appdirs wcwidth setuptools
            rtf_tokenize plover_stroke
          ];

          dontWrapQtApps = true;

          preFixup = ''
            makeWrapperArgs+=("''${qtWrapperArgs[@]}")
          '';
        };
      in
      {
        packages.default = plover;
      }
    );
}
