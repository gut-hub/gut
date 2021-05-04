use gut_lib;
use std::env;

mod plugin;

use plugin::Plugins;

fn main() {
    // get arguments
    let args: Vec<String> = env::args().collect();

    // get list of plugins
    let plugins = Plugins::new();

    // no arguments provided
    if args.len() == 1 {
        return help(plugins);
    }

    if args[1] == "-v" {
        version();
    } else if args[1] == "-h" {
        help(plugins);
    } else {
        // invoke plugin
        plugins.invoke_plugin(args[1].clone());
    }
}

fn help(plugins: Plugins) {
    println!("usage: gut [command]");
    println!("");
    println!("commands:");
    println!("");

    // iterate over plugins
    for plugin in plugins.get_plugins() {
        let names = plugin.get_functions();
        let descriptions = plugin.get_descriptions();

        for (i, _) in names.iter().enumerate() {
            gut_lib::display::write_column(names[i].clone(), descriptions[i].clone(), None)
        }
    }
}

fn version() {
    println!("{}", env!("CARGO_PKG_VERSION"));
}
