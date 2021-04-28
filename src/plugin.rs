use libloading::{Library, Symbol};
use std::fs;

use crate::gut;

#[derive(Clone, Debug, Default)]
pub struct Plugin {
    descriptions: Vec<String>,
    functions: Vec<String>,
    names: Vec<String>,
    path: String,
}

impl Plugin {
    pub fn get_descriptions(&self) -> Vec<String> {
        self.descriptions.clone()
    }

    pub fn get_functions(&self) -> Vec<String> {
        self.functions.clone()
    }

    pub fn get_names(&self) -> Vec<String> {
        self.names.clone()
    }
}

#[derive(Clone, Debug, Default)]
pub struct Plugins {
    plugins: Vec<Plugin>,
}

impl Plugins {
    pub fn new() -> Self {
        let mut plugins: Vec<Plugin> = Vec::new();

        // iterate over all plugins
        for path in Self::get_plugin_paths().into_iter() {
            unsafe {
                // create plugin libraries
                let library = Library::new(path.to_owned()).unwrap();
                let lib_export_descriptions: Symbol<unsafe fn() -> String> =
                    library.get(b"gut_export_descriptions").unwrap();
                let lib_export_functions: Symbol<unsafe fn() -> String> =
                    library.get(b"gut_export_functions").unwrap();
                let lib_export_names: Symbol<unsafe fn() -> String> =
                    library.get(b"gut_export_names").unwrap();

                // invoke exported plugin functions
                let descriptions_unparsed = lib_export_descriptions();
                let functions_unparsed = lib_export_functions();
                let names_unparsed = lib_export_names();

                // parse data
                let descriptions: Vec<String> = serde_json::from_str(&descriptions_unparsed)
                    .expect("Failed to parse plugin descriptions");
                let functions: Vec<String> = serde_json::from_str(&functions_unparsed)
                    .expect("Failed to parse plugin functions");
                let names: Vec<String> =
                    serde_json::from_str(&names_unparsed).expect("Failed to parse plugin names");

                // push to list of plugins
                plugins.push(Plugin {
                    descriptions,
                    functions,
                    names,
                    path,
                });
            }
        }

        Plugins { plugins }
    }

    pub fn get_plugins(&self) -> Vec<Plugin> {
        self.plugins.clone()
    }

    fn get_plugin_paths() -> Vec<String> {
        // read gut directory
        let paths = match fs::read_dir(gut::get_gut_dir()) {
            Ok(dir) => dir,
            Err(_) => panic!("Failed to read directory"),
        };
        // get all files
        let plugin_paths: Vec<String> = paths
            .map(|dir| {
                let entry = match dir {
                    Ok(dir) => dir,
                    Err(_) => panic!("Failed to unwrap directory"),
                };
                match entry.path().to_str() {
                    Some(path) => path.to_string(),
                    None => panic!("Failed to convert directory to string"),
                }
            })
            .collect();
        // filter out files
        let filtered: Vec<String> = plugin_paths
            .into_iter()
            .filter(|path| {
                if path.contains(".dylib") {
                    return true;
                }
                false
            })
            .collect();
        filtered
    }

    pub fn invoke_plugin(&self, name: String) {
        // iterate over plugins
        for plugin in &self.plugins {
            // check each plugin for function
            if plugin.names.contains(&name) {
                unsafe {
                    // create plugin library
                    let library = Library::new(plugin.path.to_owned()).unwrap();
                    let lib_fn: Symbol<unsafe fn()> = library.get(name.as_bytes()).unwrap();

                    // invoke exported plugin
                    lib_fn();
                }
            }
        }
    }
}
