{
  description = "Plover flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, utils, ... }: 
    utils.lib.eachDefaultSystem (system: 
      let 
        pkgs = import nixpkgs { inherit system; };
        rtf_tokenize = with pkgs.python3Packages; buildPythonPackage rec {
          name = "plover_stroke";
          version = "1.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "openstenoproject";
            repo = name;
            rev = version;
            sha256 = "sha256-A75OMzmEn0VmDAvmQCp6/7uptxzwWJTwsih3kWlYioA=";
          };
        };
        plover_stroke = with pkgs.python3Packages; buildPythonPackage rec {
          name = "rtf_tokenize";
          version = "1.0.0";

          src = pkgs.fetchFromGitHub {
            owner = "openstenoproject";
            repo = name;
            rev = version;
            sha256 = "sha256-zwD2sRYTY1Kmm/Ag2hps9VRdUyQoi4zKtDPR+F52t9A=";
          };
        };
        plover = with pkgs.python3Packages; pkgs.qt5.mkDerivationWith buildPythonPackage rec {
          name = "plover";
          version = "4.0.0rc2";

          src = pkgs.fetchFromGitHub {
            owner = "openstenoproject";
            repo = "plover";
            rev = "v${version}";
            sha256 = "sha256-rmMec/BbvOJ92u8Tmp3Kv2YezzJxB/L8UrDntTDSKj4=";
          };

          nativeCheckInputs = [ pytest mock pytest-qt ];
          doCheck = false;
          postPatch = "sed -i /PyQt5/d setup.cfg";

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
