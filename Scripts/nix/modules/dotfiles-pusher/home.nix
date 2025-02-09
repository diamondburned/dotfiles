{
  self,
  ...
}:

{
  imports = [
    self.homeModules.schedules
  ];

  # Automatically push dotfiles.
  services.user.schedules."dotfiles-pusher" = {
    description = "Automatically push dotfiles";
    calendar = "hourly";
    script = ''
      cd ~/ && git add -A && git commit -m Update && git pull --rebase && git push origin
      exit 0
    '';
  };
}
