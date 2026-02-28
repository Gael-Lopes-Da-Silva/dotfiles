{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      git
    ];

    programs.git = {
      enable = true;

      settings = {
        user = {
          name = "gael-lopes-da-silva";
          email = "gael.lopes-da-silva@outlook.fr";
        };

        credential.helper = "store";

        push = {
          default = "current";
          followTags = true;
          autoSetupRemote = true;
        };

        fetch.recurseSubmodules = "on-demand";

        pull = {
          default = "current";
          rebase = true;
        };

        rebase = {
          autoStash = true;
          missingCommitsCheck = "warn";
        };

        branch.sort = "-committerdate";
        tag.sort = "-taggerdate";

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

        init.defaultBranch = "main";

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

        color.ui = "auto";

        alias = {
          prune = "fetch --prune";
          undo = "reset --soft HEAD^";
        };
      };
    };
  };
}
