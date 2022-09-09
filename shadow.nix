{ pkgs ? (import <nixpkgs> {}), game }:
pkgs.buildEnv {
    name = "shadow-setup";
    postBuild = ''
      mkdir -p $out/var/empty $out/home/zork $out/run
    '';
    paths = [
      (
      pkgs.writeTextDir "etc/shadow" ''
        root:!x:::::::
        sshd:!x:::::::
        zork:$6$mXvH05umiRGrM.Fe$hw8XDJuQ.7HkBRiBxuJGg5EoK8mT37vo.vWfkm2HzbPki2LfSbSJU1DaEkUwBD2BV/kIGKRvpacSEPVi3yZ2q.:::::::
      ''
      )
      (
      pkgs.writeTextDir "etc/passwd" ''
        root:x:0:0::/root:/dev/null
        sshd:x:74:74::/var/empty:/dev/null
        zork:x:1000:1000::/home/zork:${game}
      ''
      )
      (
      pkgs.writeTextDir "etc/group" ''
        root:x:0:
        sshd:x:74:
        zork:x:1000:
      ''
      )
      (
      pkgs.writeTextDir "etc/gshadow" ''
        root:x::
        sshd:x::
        zork:x::
      ''
      )
    ];
  }