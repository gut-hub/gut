# gut

Collection of plugins that simplifies development workflow

## Core Plugins:
* [gut](#gut) - Core component
* [gut-cert](#gut-cert) - Certificate helpers
* [gut-color](#gut-color) - ANSI/VT100 color helpers
* [gut-column](#gut-column) - Creates text columns
* [gut-env](#gut-env) - ENV store
* [gut-git](#gut-git) - Git utilities
* [gut-kv](#gut-kv) - Key/Value store
* [gut-menu](#gut-menu) - Creates a selectable menu
* [gut-time](#gut-time) - Unix timestamp helpers
* [gut-update](#gut-update) - Updates gut

## Dependencies:
* awk
* base64
* cat
* curl
* date
* echo
* git
* grep
* openssl
* read
* sed
* tr
* wc

## Install

```
$ curl -sSL https://github.com/jareddlc/gut/raw/master/install.sh | sh
```

This will create the env `$GUT_HOME` which defaults to `$HOME/.gut`

## Usage
Gut has autocomplete support

```bash
$ gut -h
```

### Plugins

Gut has a simple "plugin" support in which it will attempt to read files placed in the `$GUT_HOME` directory and look for the following lines:

* GUT_EXPORT_FUNCTIONS - exact name of the function as written in the plugin
* GUT_EXPORT_NAMES - name that will appear in the gut help menu
* GUT_EXPORT_DESCRIPTIONS - description that will appear in the gut help menu

Here is an example of the "update plugin"

```bash
GUT_EXPORT_FUNCTIONS=("_gut_update")
GUT_EXPORT_NAMES=("update")
GUT_EXPORT_DESCRIPTIONS=("Updates gut")
```

### Contributing
Want to contribute to the project? Follow the style guide for submiting pull requests.

### Style guide

* Functions names are written in `snake_case` and must start with filename: `myfile_myfunction() {...}`
* Strings are enclosed with braces: `${my_string}`
* Variables are written in 'snake_case'
* Variable assignments via functions are called using subshells: `local encoded_key=$(echo "${key}" | base64)`
* Local variable names are written in lowercase
* Global variable names are written in uppercase
* Comments start with uppercase

### Docs

```
# Function summary
# @param {type} name - Description
function_name() {...}
```
