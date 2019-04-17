{ pkgs ? (import <nixpkgs> {}) }: with pkgs; with pkgs.lib;
let
  savedir = "/data/savegames";

  game = writeScript "game.sh" ''
    #!${runtimeShell}
    cd ${savedir}
    ${frotz}/bin/frotz ${./ZORK1.DAT}
  '';

  entry = writeScript "entry.sh" ''
    #!${runtimeShell}
    set -e

    mkdir -p ${savedir}
    chown zork ${savedir}
    chmod 755 ${savedir}

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
    mkdir /run
    trap stop SIGINT SIGTERM
    ${openssh}/bin/sshd -eDf "${./sshd_config}"
  '';
in
{

  contents = with pkgs; [ coreutils openssh ];

  config = {
    Entrypoint = [ entry ];
    ExposedPorts = {
     "22/tcp" = {};
    };
  };
  runAsRoot = ''
    #!${runtimeShell}
    ${dockerTools.shadowSetup}
    ${shadow}/bin/useradd -r -u 74 sshd
    ${shadow}/bin/useradd -s ${game} -N -M zork
    echo "zork:zork" | ${shadow}/bin/chpasswd
    mkdir -p /var/empty
  '';
}
