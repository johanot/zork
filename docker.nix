{ pkgs ? (import <nixpkgs> {}) }: with pkgs; with pkgs.lib;
let
  savedir = "/home/zork";

  game = writeScript "game.sh" ''
    #!${runtimeShell}
    cd ${savedir}
    ${frotz}/bin/frotz ${./ZORK1.DAT}
  '';

  entry = writeScript "entry.sh" ''
    #!${runtimeShell}
    set -e

    if [ ! -f /data/ssh_host_rsa_key ]; then
      ssh-keygen -f /data/ssh_host_rsa_key -N "" -t rsa
    fi
    if [ ! -f /data/ssh_host_dsa_key ]; then
      ssh-keygen -f /data/ssh_host_dsa_key -N "" -t dsa
    fi

    stop() {
      echo "Received SIGINT or SIGTERM. Shutting down"
      PID=$(cat /run/sshd.pid)
      wait $PID
    }

    echo "Starting sshd"
    trap stop SIGINT SIGTERM
    ${openssh}/bin/sshd -eDf "${./sshd_config}"
  '';
in
{

  contents = with pkgs; [ coreutils openssh (import ./shadow.nix { inherit pkgs game; })];

  config = {
    Entrypoint = [ entry ];
    ExposedPorts = {
     "22/tcp" = {};
    };
  };
}
