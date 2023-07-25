{
  description = "A Flake for my neovim configuration";

  inputs = {};

  outputs = { self }: {
    foo = {
    neovim = import ./neovim.nix;
    };
  };
}
