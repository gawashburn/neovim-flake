{
  description = "A Flake for my neovim configuration";

  inputs = {};

  outputs = { self }: {
    neovim = import ./neovim.nix;
  };
}
