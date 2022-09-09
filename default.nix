{ pkgs ? (import <nixpkgs> {}) }:

pkgs.dockerTools.buildLayeredImage ((import ./docker.nix { inherit pkgs; }) // { name = "zork"; })
