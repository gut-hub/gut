use std::fs;
use wasmer::{Array, Instance, Memory, Module, NativeFunc, Store, Value, WasmPtr};
use wasmer_wasi::WasiState;

use crate::gut_lib;

#[derive(Clone, Debug, Default)]
pub struct Plugin {
    descriptions: Vec<String>,
    functions: Vec<String>,
    path: String,
}

impl Plugin {
    pub fn get_descriptions(&self) -> Vec<String> {
        self.descriptions.clone()
    }

    pub fn get_functions(&self) -> Vec<String> {
        self.functions.clone()
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
            // create default store
            let store = Store::default();

            // create module from plugin path
            let module = Module::from_file(&store, &path).expect("Failed to load module");

            // create an environment
            let mut wasi_env = WasiState::new("Gut")
                .finalize()
                .expect("Failed to create wasi env");

            // create imports
            let import_object = wasi_env
                .import_object(&module)
                .expect("Failed to create import object");

            // create instance of wasm plugin
            let instance =
                Instance::new(&module, &import_object).expect("Failed to create instance");

            // create memory of the wasm plugin
            let memory: &Memory = instance
                .exports
                .get_memory("memory")
                .expect("Failed to get instance memory");

            // define gut export functions
            let functions: NativeFunc<(), WasmPtr<u8, Array>> = instance
                .exports
                .get_native_function("gut_export_functions")
                .expect("Failed to define gut_export_functions");
            let descriptions: NativeFunc<(), WasmPtr<u8, Array>> = instance
                .exports
                .get_native_function("gut_export_descriptions")
                .expect("Failed to define gut_export_descriptions");

            // invoke gut export functions
            let functions_ptr: WasmPtr<u8, Array> = functions
                .call()
                .expect("Failed to call gut_export_functions");
            let descriptions_ptr: WasmPtr<u8, Array> = descriptions
                .call()
                .expect("Failed to call gut_export_descriptions");

            // get strings from memory
            let functions_str = unsafe {
                functions_ptr
                    .get_utf8_str_with_nul(memory)
                    .expect("Failed to get array from memory")
            };
            let descriptions_str = unsafe {
                descriptions_ptr
                    .get_utf8_str_with_nul(memory)
                    .expect("Failed to get array from memory")
            };

            // parse json strings
            let descriptions: Vec<String> = serde_json::from_str(&descriptions_str)
                .expect("Failed to parse plugin descriptions");
            let functions: Vec<String> =
                serde_json::from_str(&functions_str).expect("Failed to parse plugin functions");

            // push to list of plugins
            plugins.push(Plugin {
                descriptions,
                functions,
                path,
            });
        }

        Plugins { plugins }
    }

    pub fn get_plugins(&self) -> Vec<Plugin> {
        self.plugins.clone()
    }

    fn get_plugin_paths() -> Vec<String> {
        // read gut directory
        let paths = match fs::read_dir(gut_lib::dir::get_gut_dir()) {
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
                if path.contains(".wasm") {
                    return true;
                }
                false
            })
            .collect();
        filtered
    }

    pub fn invoke_plugin(&self, name: String, argument: String) {
        // iterate over plugins
        for plugin in &self.plugins {
            // check each plugin for function
            if plugin.functions.contains(&name) {
                // create default store
                let store = Store::default();
                // create module from plugin path
                let module =
                    Module::from_file(&store, &plugin.path).expect("Failed to create module");
                // create an environment
                let mut wasi_env = WasiState::new("Gut")
                    .finalize()
                    .expect("Failed to create wasi env");
                // create imports
                let import_object = wasi_env
                    .import_object(&module)
                    .expect("Failed to create import object");
                // create instance of wasm plugin
                let instance =
                    Instance::new(&module, &import_object).expect("Failed to create instance");
                // create memory of the wasm plugin
                let memory: &Memory = instance
                    .exports
                    .get_memory("memory")
                    .expect("Failed to get instance memory");
                // create function definition
                let lib_fn = instance
                    .exports
                    .get_function(&name)
                    .expect("Failed to get function");

                // write the string into the lineary memory
                for (byte, cell) in argument
                    .bytes()
                    .zip(memory.view()[0 as usize..(argument.len()) as usize].iter())
                {
                    cell.set(byte);
                }

                // invoke function
                lib_fn
                    .call(&[Value::I32(0), Value::I32(argument.len() as _)])
                    .expect("Failed to invoke function");
            }
        }
    }
}
