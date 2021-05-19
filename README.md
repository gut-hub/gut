# gut

Collection of plugins that simplifies development workflow

* [gut-plugin](https://github.com/gut-hub/gut-plugin)
* [gut-lib](https://github.com/gut-hub/gut-lib)

## Install

This will create the gut directory: `$HOME/.gut`

```
MacOS
$ curl -sSL https://github.com/gut-hub/gut/raw/master/install.sh | sh
```

## Plugins

The gut plugin system loads plugins that are located in the gut directory `$HOME/.gut`.
Plugins are written in rust and can be compiled to either `native` or `wasm`.

See [gut-plugin](https://github.com/gut-hub/gut-plugin)

## Library

Helper library that provides common functionality for Gut

See [gut-lib](https://github.com/gut-hub/gut-lib)
