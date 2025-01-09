{
  # Define URLs/references to package sources. See https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-flake for more information on references/syntax.
  inputs = {
    stable.url = "github:NixOS/nixpkgs?ref=nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  # Define packages to use as well as the instructions for building the dev shell.
  outputs =
    # List inputs, the ellipsis indicates that anything else passed to this flake at runtime is also usable (not super relevant here, moreso for other types of flakes)
    { stable, unstable, ... }: {
      # This is the main command. Everything else below is part of the definition of this dev shell. 
      # The contents of the dev shell are enumerated by the "in" phrase at the bottom, and the contents of the "let" phrase define the packages to be invoked within the "in" section. 
      # Analagous to math syntax defining a function: give a function name, define the parameters/domains of variables, then write out the function in terms of those parameters/variables.
      devShells.x86_64-linux =

        # Start of the "let" definition section of the dev shell.
        let
          pkgs = stable.legacyPackages.x86_64-linux;
          upkgs = unstable.legacyPackages.x86_64-linux;

          # Packages not contained in CRAN must be built using the below syntax in this section of the flake.

          # Builds an R package from a github repository. 
          hdWGCNA = upkgs.rPackages.buildRPackage {
            name =
              "hdWGCNA"; # Define package name in R. This is the name you'll use for `library()` or to specify which package to pull a function from.
            src = upkgs.fetchFromGitHub {
              owner =
                "smorabit"; # GitHub repo owner. GitHub URL is of the form "github.com/<OWNER>/<REPO>", use <OWNER>.
              repo = "hdWGCNA";
              rev =
                "8280ba5dc375bc44d92a312a5ff7a7b95aee2d85"; # Obtain the "rev" value from the github page, then to determine sha256, leave blank and run `nix develop`.
              sha256 =
                "1akq0xzrsdw4wmq0vz09m88ri4dq3aljs8g70mmvqx5nsk3jiam4"; # It will return an error message that contains the sha256 value for that github revision.

            };
            propagatedBuildInputs =
              with upkgs.rPackages; [ # List dependencies of package. To determine, first leave blank and then run `nix develop`.
                WGCNA # It will return an error that lists necessary dependencies.
                igraph # If dependencies are in nixpkgs, list here (whitespace separated, no commas/semicolons)
                Seurat # If dependencies are not in nixpkgs, build them using the buildRPackage() function above the current one, then call here.
                harmony
                tester
                proxy
              ];

          };

          loomR = upkgs.rPackages.buildRPackage {
            name = "loomR";
            src = upkgs.fetchFromGitHub {
              owner = "mojaveazure";
              repo = "loomR";
              rev = "df0144bd2bbceca6fadef9edc1bbc5ca672d4739";
              sha256 = "1b1g4dlmfdyhn56bz1mkh9ymirri43wiz7rjhs7py3y7bdw1s3yr";
            };
            propagatedBuildInputs = with upkgs.rPackages; [
              R6
              hdf5r
              iterators
              itertools
              Matrix
            ];
          };

          seuratwrappers = upkgs.rPackages.buildRPackage {
            name = "SeuratWrappers";
            src = upkgs.fetchFromGitHub {
              owner = "satijalab";
              repo = "seurat-wrappers";
              rev = "8d46d6c47c089e193fe5c02a8c23970715918aa9";
              sha256 = "1ldb0m714jg4c6nkvvz1rcmzykcm175jhf1i72i0v4y1vrc77md3";
            };
            propagatedBuildInputs = with upkgs.rPackages; [
              BiocManager
              cowplot
              ggplot2
              igraph
              Matrix
              remotes
              rsvd
              Seurat
              rlang
              R_utils
            ];
          };

          SeuratDisk = upkgs.rPackages.buildRPackage {
            name = "SeuratDisk";
            src = upkgs.fetchFromGitHub {
              owner = "mojaveazure";
              repo = "seurat-disk";
              rev = "877d4e18ab38c686f5db54f8cd290274ccdbe295";
              hash = "sha256-tQXes2KRHFpH8mSY4DCdqBHzcMx0okt1SbN6XdLESVU=";
            };
            propagatedBuildInputs = with upkgs.rPackages; [
              cli
              crayon
              hdf5r
              Matrix
              R6
              rlang
              Seurat
              SeuratObject
              stringi
              withr
            ];
          };

          monocle3 = upkgs.rPackages.buildRPackage {
            name = "monocle3";
            src = upkgs.fetchFromGitHub {
              owner = "cole-trapnell-lab";
              repo = "monocle3";
              rev = "98402ed0c10cac020524bebbb9300614a799f6d1";
              sha256 = "1qs4qcdz9hcq966qcr7xvkpx3ri8g1n5psfwik09m7ngzpdd1r5q";
              fetchSubmodules = true;
            };
            propagatedBuildInputs = with upkgs.rPackages; [
              assertthat
              dplyr
              future
              ggrepel
              grr
              leidenbase
              lmtest
              openssl
              pbapply
              pbmcapply
              pheatmap
              plotly
              plyr
              proxy
              pscl
              purrr
              RANN
              reshape2
              rsample
              RhpcBLASctl
              RcppAnnoy
              Rtsne
              sf
              shiny
              slam
              spdep
              speedglm
              stringr
              uwot
              tidyr
              viridis
              BiocManager
              BiocGenerics
              DelayedArray
              DelayedMatrixStats
              limma
              lme4
              S4Vectors
              SingleCellExperiment
              SummarizedExperiment
              batchelor
              HDF5Array
              terra
              ggrastr
            ];
          };

          presto = upkgs.rPackages.buildRPackage {
            name = "presto";
            src = upkgs.fetchFromGitHub {
              owner = "immunogenomics";
              repo = "presto";
              rev = "7636b3d0465c468c35853f82f1717d3a64b3c8f6";
              sha256 = "sha256-Sfjx5e0drUrRA9f0gxmeN8Z3cdz6Q3LBVWM3tV6k8R0=";
              fetchSubmodules = true;
            };
            propagatedBuildInputs = with upkgs.rPackages; [
              Rcpp
              dplyr
              tidyr
              purrr
              tibble
              Matrix
              rlang
              RcppArmadillo
              data_table
            ];
          };

          DoubletFinder = upkgs.rPackages.buildRPackage {
            name = "DoubletFinder";
            src = upkgs.fetchFromGitHub {
              owner = "chris-mcginnis-ucsf";
              repo = "DoubletFinder";
              rev = "03e9f37f891ef76a23cc55ea69f940c536ae8f9f";
              hash = "sha256-d7U6rryThcgJbfIs6TeBJv7+0LPWMONuwiJsT0ckbjk=";
              fetchSubmodules = true;
            };
            propagatedBuildInputs = with upkgs.rPackages; [
              fields
              KernSmooth
              ROCR
            ];
          };

          # Additional R packages to manually define go here.

          # This clause defines the packages included in the dev shell. When you run `nix develop`, it will evaluate this list and build those packages. 
          # Note that for R packages, you must still load packages with the `library()` command. To make this process easier, use the "easypackages" package to load multiple packages at once.
        in {
          default = upkgs.mkShell {
            # Syntax: packages available in nixpgs repo (i.e. all CRAN packages) are loaded with "upkgs.rPackages.<NAME>" to pull from nixpkgs. Packages defined above are loaded via the name assigned to them.
            packages = [
              upkgs.R
              upkgs.rPackages.easypackages
              upkgs.rPackages.Seurat
              upkgs.rPackages.SingleCellExperiment
              upkgs.rPackages.scater
              upkgs.rPackages.patchwork
              upkgs.rPackages.sctransform
              upkgs.rPackages.dplyr
              upkgs.rPackages.ggplot2
              upkgs.rPackages.ggraph
              upkgs.rPackages.igraph
              upkgs.rPackages.tidyverse
              upkgs.rPackages.data_tree
              upkgs.rPackages.HGNChelper
              upkgs.rPackages.magrittr
              upkgs.rPackages.UCell
              upkgs.rPackages.corrplot
              upkgs.rPackages.cowplot
              upkgs.rPackages.repr
              upkgs.rPackages.IRdisplay
              upkgs.rPackages.IRkernel
              upkgs.rPackages.DESeq2
              upkgs.rPackages.gprofiler2
              upkgs.rPackages.clustree
              upkgs.rPackages.openxlsx
              upkgs.rPackages.glmGamPoi
              upkgs.rPackages.devtools
              upkgs.rPackages.UpSetR
              upkgs.rPackages.scCustomize
              upkgs.rPackages.speckle
              upkgs.rPackages.ggvenn
              upkgs.rPackages.ggVennDiagram
              seuratwrappers
              loomR
              monocle3
              hdWGCNA
              presto
              DoubletFinder
              SeuratDisk
            ];
          };
        };
    };
}
