{ ... }:

{
  hardware = {
    uinput.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
}
