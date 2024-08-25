use gut_lib;
use std::env;

mod download;
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

    if args[1] == "-v" || args[1] == "version" {
        version();
    } else if args[1] == "-h" || args[1] == "help" {
        help(plugins);
    } else if args[1] == "-d" || args[1] == "download" {
        download();
    } else if args[1] == "-u" || args[1] == "update" {
        update();
    } else {
        // passthrough argument to invoke plugin
        let mut passthrough = "".to_string();
        if args.len() > 2 && !args[2].is_empty() {
            passthrough = args[2].clone();
        }

        // invoke plugin
        plugins.invoke_plugin(args[1].clone(), passthrough);
    }
}

fn help(plugins: Plugins) {
    println!("usage: gut [command]");
    println!("");
    println!("commands:");
    // default options
    gut_lib::display::write_column(
        "-h, help".to_string(),
        "Prints this message".to_string(),
        None,
    );
    gut_lib::display::write_column(
        "-v, version".to_string(),
        "Prints the version".to_string(),
        None,
    );
    gut_lib::display::write_column(
        "-d, download".to_string(),
        "Shows a list of downloadble gut plugins".to_string(),
        None,
    );
    gut_lib::display::write_column(
        "-u, update".to_string(),
        "Downloads the latest gut version".to_string(),
        None,
    );

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

fn update() {
    // determine gut version to download
    let mut file_name = "".to_string();
    if env::consts::OS == "macos" {
        // check arch
        if env::consts::ARCH == "aarch64" {
            file_name = "gut-macos-aarch64".to_string();
        } else {
            file_name = "gut-macos-x86".to_string();
        }
    } else if env::consts::OS == "linux" {
        file_name = "gut-linux".to_string();
    } else if env::consts::OS == "windows" {
        file_name = "gut.exe".to_string();
    }

    download::download_gut(file_name);
}

fn download() {
    // get list of gut plugins
    let plugins = download::get_plugins();

    // create display friendly array
    let mut plugins_names = vec![];
    for plugin in &plugins {
        let name = match plugin["name"].as_str() {
            Some(name) => name.to_string(),
            None => panic!("Failed to get plugin name"),
        };

        let description = match plugin["description"].as_str() {
            Some(description) => description.to_string(),
            None => panic!("Failed to get plugin description"),
        };

        plugins_names.push(format!("{} - {}", name, description));
    }

    // prompt user for plugin selection
    let selection = gut_lib::display::select_from_list(&plugins_names, None);

    // crete display friendly array
    let mut plugin_type = vec![];
    if !&plugins[selection]["linux"].is_null() {
        plugin_type.push("linux".to_string());
    }
    if !&plugins[selection]["macos"].is_null() {
        plugin_type.push("macos".to_string());
    }
    if !&plugins[selection]["windows"].is_null() {
        plugin_type.push("windows".to_string());
    }
    if !&plugins[selection]["wasm"].is_null() {
        plugin_type.push("wasm".to_string());
    }

    // prompt user for plugin os
    let selection_type = gut_lib::display::select_from_list(&plugin_type, None);

    // get plugin info
    let repo = match &plugins[selection]["repo"].as_str() {
        Some(repo) => repo.to_string(),
        None => panic!("Failed to get plugin repository"),
    };
    let release = match &plugins[selection]["release"].as_str() {
        Some(release) => release.to_string(),
        None => panic!("Failed to get plugin repository"),
    };
    let file_name = match &plugins[selection][&plugin_type[selection_type]].as_str() {
        Some(name) => name.to_string(),
        None => panic!("Failed to get plugin repository"),
    };

    // download plugin
    download::download_plugin(repo, release, file_name);
}
