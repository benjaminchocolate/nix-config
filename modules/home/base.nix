{
  flake.modules.homeManager.base = {
    xdg.enable = true;
    home.preferXdgDirectories = true;

    home.file.".hushlogin".text = "";
    home.file.".clang-format".text = ''
      BasedOnStyle: Google
    '';
  };
}
