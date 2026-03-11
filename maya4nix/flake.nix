{
  description = ''
    Maya 2024.2 Nix Flake - Autodesk Maya 3D Animation and Modeling Software
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        # Import our Maya derivation
        maya2024 = pkgs.callPackage ./maya2024.nix {
          # TODO change this path to the absolute path on your system
          mayaRpm = ~/workspace/maya4linux/Autodesk_Maya_2024_2_Update_Linux_64bit/Packages;
        };

        # Development shell with Maya
        mayaDevShell = pkgs.mkShell {
          name = "maya-dev-shell";
          buildInputs = with pkgs; [
            maya2024
          ];
          
          shellHook = ''
            echo "🎨 Maya 2024.2 Development Environment"
            echo "======================================"
            echo ""
            echo "Available commands:"
            echo "  maya2024  - Launch Maya GUI"
            echo "  mayapy2024 - Launch Maya Python interpreter"
            echo "  AdskLicensingService13 - Launch Autodesk Licensing Service"
            echo "  AdskLicensingInstHelper13 - Launch Autodesk Licensing Installation Helper"
            echo ""
            echo "Maya installation: ${maya2024}"
            echo ""
            
            # Add Maya binaries to PATH
            export PATH="${maya2024}/bin:$PATH"
          '';
        };

      in
      {
        # Packages available for installation
        packages = {
          maya = maya2024;
          default = maya2024;
        };

        # Applications that can be run with 'nix run'
        apps = {
          maya = {
            type = "app";
            program = "${maya2024}/bin/maya2024";
          };
          mayapy = {
            type = "app";
            program = "${maya2024}/bin/mayapy2024";
          };
          adskLicensingService = {
            type = "app";
            program = "${maya2024}/bin/AdskLicensingService13";
          };
          adskLicensingInstHelper = {
            type = "app";
            program = "${maya2024}/bin/AdskLicensingInstHelper13";
          };
          default = self.apps.${system}.maya;
        };

        # Development shell
        devShells = {
          default = mayaDevShell;
          maya = mayaDevShell;
        };

        # Formatter for nix files
        formatter = pkgs.nixpkgs-fmt;

        # Checks for CI/testing
        checks = {
          # Basic derivation build test
          maya-builds = maya2024;
        };
      }
    );

  # Flake-level metadata
  nixConfig = {
    # Suggest enabling unfree packages
    allowUnfree = true;
    # Optional: Add custom binary caches if you have them
    # extra-substituters = [ "https://your-cache.example.com" ];
    # extra-trusted-public-keys = [ "your-key-here" ];
  };
}