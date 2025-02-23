{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      initScript = pkgs.writeTextDir "/app/init.sh" (builtins.readFile ./init.sh);

      dockerImage = pkgs.dockerTools.buildImage {
        name = "pure-ftpd-anon";
        architecture = "amd64";

        copyToRoot = pkgs.buildEnv {
          name = "root-layer";
          paths = [ pkgs.pure-ftpd pkgs.bash pkgs.coreutils pkgs.shadow initScript ];
          pathsToLink = [ "/bin" "/app" ];
        };

        config = {
          Entrypoint = [ "/bin/bash" "/app/init.sh" ];
          Volumes = {
            "/data" = {};
          };
          ExposedPorts = {
            "21" = {};
            "30000" = {};
            "30001" = {};
            "30002" = {};
            "30003" = {};
            "30004" = {};
            "30005" = {};
          };
          Env = [ "FTP_UID=1000" "FTP_GID=1000" "UPLOAD_DIR_NAME=''" "PASV_PORTS='30000:30005'" ];
        };
      };

      devShell = pkgs.mkShell {
        name = "development shell";
        packages = with pkgs; [ podman skopeo jq dive inetutils ];
      };
    in
    {
      defaultPackage.x86_64-linux = dockerImage;

      devShells.x86_64-linux.default = devShell;
    };
}
