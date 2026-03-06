{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      credential.helper = "store";
      fetch.recurseSubmodules = "on-demand";
      branch.sort = "-committerdate";
      tag.sort = "-taggerdate";
      init.defaultBranch = "main";
      color.ui = "auto";

      user = {
        name = "gael-lopes-da-silva";
        email = "gael.lopes-da-silva@outlook.fr";
      };

      push = {
        default = "current";
        followTags = true;
        autoSetupRemote = true;
      };

      pull = {
        default = "current";
        rebase = true;
      };

      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };

      status = {
        branch = true;
        showStash = true;
        submoduleSummary = true;
        showUntrackedFiles = "all";
      };

      log = {
        abbrevCommit = true;
        follow = true;
        decorate = false;
      };

      core = {
        compression = 9;
        editor = "nvim";
        pager = "less";
        whitespace = "-trailing-space";
        preloadindex = true;
      };

      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };

      diff = {
        context = 3;
        interHunkContext = 10;
        mnemonicPrefix = true;
        renames = true;
        submodule = "log";
      };

      grep = {
        break = true;
        heading = true;
        lineNumber = true;
      };

      rerere = {
        autoupdate = true;
        enabled = true;
      };

      alias = {
        prune = "fetch --prune";
        undo = "reset --soft HEAD^";
      };
    };
  };
}
