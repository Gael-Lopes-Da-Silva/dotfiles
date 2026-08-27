{ ... }:

{
  security = {
    protectKernelImage = true;
    rtkit.enable = true;
    polkit.enable = true;
  };
}
