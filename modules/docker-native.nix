{ config, lib, pkgs, ... }:
let
  cfg = config.wsl.docker-native;
in
{
  options = {
    wsl.docker-native = {
      enable = lib.mkEnableOption "Native Docker integration in NixOS.";

      addToDockerGroup = lib.mkOption {
        type = lib.types.bool;
        default = config.security.sudo.wheelNeedsPassword;
        description = ''
          Wether to add the default user to the docker group.

          This is not recommended, if you have a password, because it essentially permits unauthenticated root access.
        '';
      };
    };
  };

  config = lib.mkIf (config.wsl.enable && cfg.enable) {
    environment.systemPackages = [
      pkgs.docker-compose
    ];

    virtualisation.docker.package = pkgs.docker.override {
      iptables = pkgs.iptables-legacy;
    };
    virtualisation.docker.enable = true;

    users.groups.docker.members = lib.mkIf cfg.addToDockerGroup [
      config.wsl.defaultUser
    ];
  };
}
