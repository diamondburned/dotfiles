{ pkgs, ... }:

{
  programs.bash = {
    interactiveShellInit = ''
      ${builtins.readFile ./rc.d/git}
      ${builtins.readFile ./rc.d/blesh}
      ${builtins.readFile ./rc}
    '';
  };

  programs.bash.blesh = {
    enable = true;
  };

  home-manager.sharedModules = [
    {
      programs.bash = {
        enable = true;
        enableVteIntegration = true;
        historySize = 500000;
        historyFileSize = 1000000;
        # bashrcExtra = builtins.readFile ./rc;
      };
    }
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor # for nixrl
    lineprompt
  ];
}
