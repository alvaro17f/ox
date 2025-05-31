# OX

![](vhs/ox.gif)

`ox` is a command line tool for managing NixOS configuration.

> :warning: **Work in Progress**: This project is currently under development. Some features may not be complete and may change in the future.

## Installation

To install ox, you can clone the repository and compile the source code:

```sh
git clone https://github.com/alvaro17f/ox.git
cd ox
odin build .
```

then move the binary to a directory in your PATH:

```sh
sudo mv ox <PATH>
```

### NixOS

#### Run

To run ox, you can use the following command:

```sh
nix run github:alvaro17f/ox
```

If you need to pass arguments, you can use the following command:

```sh
nix run github:alvaro17f/ox -- help
```

#### Flake

Add ox to your flake.nix file:

```nix
{
    inputs = {
        ox.url = "github:alvaro17f/ox";
    };
}
```

then include it in your system configuration:

```nix
{ inputs, pkgs, ... }:
{
    home.packages = [
        inputs.ox.packages.${pkgs.system}.default
    ];
}
```

## Usage

```sh
 ***************************************************
 OX - A simple CLI tool to update your nixos system
 ***************************************************
 -r : set repo path (default is $HOME/.dotfiles)
 -n : set hostname (default is OS hostname)
 -k : set generations to keep (default is 10)
 -u : set update to true (default is false)
 -d : set diff to true (default is false)
 -h, help : Display this help message
 -v, version : Display the current version
```

## License

ox is distributed under the MIT license. See the LICENSE file for more information.
