{ ... }:

{
  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ./rc;
    historySize = 500000;
    historyFileSize = 1000000;
  };
}
