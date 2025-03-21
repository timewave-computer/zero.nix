{ writeShellApplication
, yq
, coreutils
, getopt
, gawk
}:
writeShellApplication {
  name = "upload-contract";
  runtimeInputs = [ yq coreutils getopt gawk ];

  text = builtins.readFile ./upload-contract.bash;
}
