# scrna-tools  
A collection of scripts and other files useful in performing single cell RNA sequencing analysis. Free to use or modify, but please note that these packages can be difficult to work with, and any changes may negatively affect compatibility.

## Requirements  
 - All software is made for computers running a Linux OS. For MacOS/Windows, using a Linux virtual machine is recommended.
 - If you do not have admin access to the computer that analysis is performed on, you will need to contact your system administrator for specific guidelines on using Nix and Docker. 
   - Note that in order for Nix to work, it normally needs root access. [Binary installation](https://github.com/burberrylab/scrna-tools#nix-package-manager-instrustions-without-sudo-or-root-access) may get around this issue, but it is not yet fully tested.
   - Docker typically requires sudo permissions to run. Note that the software contained in the docker images here require write permissions in the destination directories in order to analyze and save your data. Thus, read-only images (e.g. Singularity's .sif files) will not work.
 - R scripts are generally dependent on having the packages listed in "packages.csv". Individual scripts may not require all of those packages, but dependencies are not listed individually.
 - The R environment is created via nix flakes. Using the flake without modification does not require understanding the Nix language, but modification of it does.
 - Two pieces of software (cellranger and azimuth) were used via Docker containers. While other implementations are definitely possible, we determined this to be the most stable, replicable, and convenient way to use them given issues with other implementations. This requires Docker and Docker Compose. Your installation of Docker may already have the Docker Compose plugin. See [docs.docker.com/compose/](https://docs.docker.com/compose/) for more information.

## Instructions

### Nix flakes  
The Nix package manager creates fully declarative and reproducible environments such that if a set of packages works on one machine, it will work on any other. Using nix avoids the issues of package updates causing version conflicts and packages installed elsewhere on the system causing issues. See [nixos.org](https://nixos.org/) for official documentation and system-specific download instructions. Nix flakes are currently classified as an "experimental feature", though they are well-supported and generally considered stable. You will need to enable experimental features to use flakes. See the [nixos wiki page on flakes](https://nixos.wiki/wiki/Flakes) for detailed instructions on enabling this feature, as well as a thorough description of flake syntax and use.

#### Getting started with Nix  
The Nix package manager is separate from NixOS. NixOS is not necessary to use the Nix package manager, though it does have many benefits in a research environment where stability and reproducibility are essential. Check out the [official documentation](https://nix.dev/tutorials/first-steps/) or this [unofficial beginner's guide](https://nixos-and-flakes.thiscute.world/) if you want to learn more about Nix.

##### Nix package manager instructions (with sudo):
 1. Go to <https://nixos.org/download/> and navigate to your operating system under the "Nix : the package manager" header.
 2. Run the multi-user mode script (for Linux, it's `$ sudo sh <(curl -L https://nixos.org/nix/install) --daemon`) in your home directory.
 3. Run `$ nix --version` to verify that your installation is working.
 4. Go to your project directory and run `$ nix run nixpkgs#hello`. If it successfully prints "Hello, world!", then the nix package manager is ready to go!
Then, r
##### Nix package manager instrustions (without sudo or root access):  
Note: This may not work on all systems. If you have errors when attempting to use this, contact your system administrator for further guidance.

 1. Go to <https://releases.nixos.org/?prefix=nix/> and click on a version of Nix. Use either the latest release, or the the version used in the most recent [stable release](https://nixos.org/manual/nixos/stable/release-notes.html#ch-release-notes). At the time of writing this, I have version 2.24.10, but the latest binary release is 2.23.5.
 2. Use [Hydra](https://hydra.nixos.org/project/nix) to download a stable binary release of Nix.
    - Assuming an x86_64-linux system and Nix version 2.23, run the following:
    ```
    $ mkdir -p ~/.local/bin
    $ cd ~/.local/bin
    $ curl -L https://hydra.nixos.org/job/nix/maintenance-2.23/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist > nix
    $ chmod +x nix
    $ ./nix --version
    ```
 3. The nix package manager has now been successfully installed. Now, we add it to `$PATH` so that it can be run anywhere. Run the following to temporarily add this directory to `$PATH`:
    ```
    $ cd ~
    $ export PATH=$(pwd)/.local/bin:$PATH
    ```
 4. Now, add that export command at the end of your `~/.bashrc` file so that the change will persist.
 5. Normally, nix requires root access to write to the directory `/nix/store`. When running nix commands from the binary you've just installed, it will write packages to a local store directory. Run `$ nix run nixpkgs#hello`. You should see a warning message that '/nix/...' doesn't exist and that it will use a chroot store. Then, you should see a downloading message, followed by "Hello, world!" being printed to the terminal. If you run the command again, "Hello world!" should appear spontaneously. This indicates that you are ready to use nix flakes to manage your packages.

#### What is a flake?  
A Nix Flake is a piece of nix code that contains all of the information needed to construct an environment with desired software/packages available. This flake contains the instructions to load all of the necessary R packages for analysis of scRNA-seq data through the Seurat pipeline. Your individual project may not require all of these packages, or it may require more. ***Do not use the install.packages() R command*** or any other method of installing packages from within the R console. It will most likely not work, and if it does, it will likely cause issues. Should you need additional packages, you should [add them to the flake](https://github.com/burberrylab/scrna-tools#how-do-i-add-things-to-the-flake).

#### How do I use the flake?  
 1. Make a directory for your R analysis. I recommend that it is a separate folder from your raw data and the output of the cellranger pipeline.
 2. Download **both** the flake.nix and flake.lock file to this directory. 
 3. Run `nix develop`. The first time you run it, it will take a while to run, as it is retrieving all of the assets for all of the packages. Once it is done, you will be put back into a bash shell that looks the same (or very similar to) the one you were in before running `nix develop`. The difference is that this environment now has access to all of the packages defined in the flake.
 4. Now, just type `R` to open an interactive session, or run `R CMD BATCH script.R` to run code contained in a file called `script.R`.
 5. Once you are done, use `CTRL+D` to exit the development shell. 

#### How do I add things to the flake?  
The flake provided has comments explaining the syntax to follow when adding anything. First, search [nixpkgs](https://search.nixos.org/packages) for the package you want. If it is there, then add `upkgs.rPackages.<PACKAGE_NAME>` to the packages list at the very end of the file. There should be a line break between each entry, with no quotation marks or punctuation (spaces don't matter). If it is not there, then do the following:  
 1. Find the package's source code on GitHub. Instructions for packages that are not on GitHub are not yet available.
 2. Copy an existing build clause (e.g. `loomR = upkgs.rPackages.buildRPackage ... Matrix ]; };`) and paste it somewhere between the `let` and `in` clauses. 
 3. Then, replace the name with your package's name, replace the owner/repo with that package's owner/repo, delete the strings after `rev = ` and `hash = `, and delete the packages listed in the `propagatedBuildInputs` list.
 4. To get the values for `rev` and `sha256`, the most convenient option is the package `nix-prefetch-github`, which is available through nixpkgs. 
    - Run the command `nix shell nixpkgs#nix-prefetch-github` to create a shell in which you have access to that package. 
    - Run `nix-prefetch-github <OWNER> <REPO>`, and it will return the `rev` and `sha256` values for the master/main branch's latest commit. 
    - To get a different version:
      - Go to the "Releases" tab, then find your desired version. 
      - Click the commit icon (i.e. the icon with a 7 character-long alphanumeric string), then on the right side of the screen, click the copy icon that says "Copy full SHA for ..." when hovered over. 
      - Go back to the terminal and run `nix-prefetch-github <OWNER> <REPO> --rev <COPIED_SHA>`. You now have the `rev` and `sha` values to put into the nix flake. 
    - Type `CTRL+D` to exit the nix shell session.
 5. Next, run `nix develop`. It will most likely output an error message in which it lists missing dependencies for the package you just added. Check that each of these exist in the nixpkgs library. If they do, add them to the `propagatedBuildInputs` list. If not, manually define them using the `buildRPackage` function and place that chunk above the one you are currently working on. Continue until all package dependencies have been included. 
 6. If you do all of the above and the package you are trying to add still does not work, or it causes an error during `nix develop`, then try a different version of the package. If that does not work, attempt troubleshooting the error messages that you are getting. It may be due to version conflict between packages with the same dependencies, in which case you will have to make a separate flake for the conflicting package.

### Docker compose  
Docker allows the creation of a *container* (isolated environment) that can run an *image* (a snapshot of all of the necessary elements and packages for some software to run). This is an excellent tool for distributing software, as all dependencies are included alongside the main package. See [docs.docker.com](https://docs.docker.com/) for official documentation and installation instructions. If you do not have sudo permissions, you will need to contact your system administrator. Most institutional HPC clusters do not directly allow docker, but do have a preferred container service. Docker images can be converted into other types of image files for these services (detailed instructions coming soon).

To run the docker container, do the following:  
 1. Create a new subdirectory within your project folder.
 2. Copy the `docker-compose.yml` file into this directory. (note: there can only be one compose file in a directory, so different applications must be in separate folders)
    - You must edit the file to replace `<SOURCE>` and `<DESTINATION>` with the absolute paths of the source/reference data and the directory in which your results will be saved (e.g. `/home/user/my_project/my_cellranger_data:/home/cellranger_data`)
    - Note that the path before the colon is the path on your host machine, and the path after the colon is the path in the container.
    - Also note that if any files are written to somewhere other than the directories specified under `volumes:`, they will not be available to you upon exiting the container. Any important information **must** be saved to one of those directories. Furthermore, if you delete something in the bound directories whilst inside the container, you have also deleted them on the host machine. For safety, it is always a good idea to keep regular backups of your data.
 3. Start the docker daemon: 
    - If you are in the `docker` group or have sudo permission, use `sudo systemctl docker start`.
    - If you cannot do that, contact your system administrator.
 4. Run `docker compose run <SERVICE_NAME>`, where `<SERVICE_NAME>` is the word that appears after `services:` in the compose file. For clarity, the name and the service in the provided files are the same.
 5. You are now in a bash shell within the container. Navigate to the directory your data is in (in the example above, `/home/cellranger_data`).
 6. Use the software as normal. 
    - If a port is specified in the compose file (i.e. the Azimuth file), then that port is accessible in the docker container. For example, if you start the Azimuth container, then from within that, run AzimuthApp() in R, you should be able to use the browser version at address `localhost:3838`).
    - Make sure to save all data into a directory bound to the host machine!
