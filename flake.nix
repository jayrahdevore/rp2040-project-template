{
  description = "Imaging hardware research repo";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # idl = {
    #   # url = "git+ssh://git@github.com/BadgerTechnologies/ImageDetectionLibrary?ref=experimental-nix-build";
    #   url = "path:/src/ImageDetectionLibrary";
    # };

    # tensorrt = { # this is for tensor-rt
    # not supported yet
    # What we'll have to do is manually download the file from NVidia and add it to the nix store with
    # 'nix-store --add-fixed sha256 TensorRT-8.5.3.1.Linux.x86_64-gnu.cuda-11.8.cudnn8.6.tar.gz'
    # 
    #   NOTE: The version in s3 isn't the same as the one requested by the flake
    #
    #   url = "s3://fugatebt/JenkinsTest/TensorRT-8.6.0.12_p38_cuda-11.8_prebuilt.tar.gz";
    # };

  };

  outputs = { self , nixpkgs, fenix, ... }: let
    # system should match the system you are running on
    system = "x86_64-linux";
    target = "thumbv6m-none-eabi";
    toolchain = with fenix.packages.${system}; combine[
      minimal.cargo
      minimal.rustc
      targets.${target}.latest.rust-std
    ];
    python-deps = ps: with ps; [

      # (
      #   buildPythonPackage rec {
      #     pname = "numpy-hilbert-curve"; # for beanie
      #     version = "1.0.1";
      #     src = fetchPypi {
      #       inherit pname version;
      #       sha256 = "sha256-B0Xb1MFrJYwYA0LW31ffqZEQudmMhqhNkg8pr1zAcHs=";
      #     };
      #     doCheck = false;
      #     format = "pyproject";
      #     propagatedBuildInputs = [
      #       setuptools
      #     ];
      #   }
      # )
    ];
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # (self: super: rec {
          # })
        ];
      };
      python-env = pkgs.python311.withPackages python-deps;
    in pkgs.mkShell {

      # create an environment with python and deps available
      # inputsFrom = [
      # ];
      nativeBuildInputs = with pkgs; [
        toolchain
        flip-link
        probe-rs
        elf2uf2-rs
      ];

      packages = with pkgs; [
        # idl.packages.${system}.default
        # python-env
        rust-analyzer
      ];

      # shellHook = ''
      # '';

    };
  };
}
