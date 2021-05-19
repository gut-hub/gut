use libloading::{Library, Symbol};
use std::ffi::CString;
use std::fs;
use std::os::raw::c_char;
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
            if path.contains(".wasm") {
                plugins.push(Self::load_wasm_plugin(&path));
            } else {
                plugins.push(Self::load_native_plugin(&path));
            }
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
                // macos
                if path.contains(".dylib") {
                    return true;
                }
                // linux
                if path.contains(".so") {
                    return true;
                }
                // windows
                if path.contains(".dll") {
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
                // load wasm
                if plugin.path.contains(".wasm") {
                    // create instance of wasm plugin
                    let instance = Self::load_wasm(&plugin.path);

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
                        .call(&[Value::I32(0)])
                        .expect("Failed to invoke function");
                } else {
                    unsafe {
                        // create instance of native plugin
                        let library = Self::load_native(&plugin.path);

                        // create function definition
                        let lib_fn: Symbol<unsafe fn(*mut c_char)> = library
                            .get(name.as_bytes())
                            .expect("Failed to create symbol library");

                        // convert string into a pointer
                        let c_string =
                            CString::new(argument.clone()).expect("Failed to create c_string");
                        let ptr = c_string.into_raw();

                        // invoke function
                        lib_fn(ptr);
                    }
                }
            }
        }
    }

    pub fn load_native_plugin(path: &String) -> Plugin {
        unsafe {
            let path = path.clone();

            // create instance of native plugin
            let library = Self::load_native(&path);

            // define gut export functions
            let lib_export_descriptions: Symbol<unsafe fn() -> *mut c_char> = library
                .get(b"gut_export_descriptions")
                .expect("Failed to create symbol library");
            let lib_export_functions: Symbol<unsafe fn() -> *mut c_char> = library
                .get(b"gut_export_functions")
                .expect("Failed to create symbol library");

            // invoke gut export functions
            let descriptions_ptr = lib_export_descriptions();
            let functions_ptr = lib_export_functions();

            // retrieve strings from pointers
            let cstring_descriptions = CString::from_raw(descriptions_ptr);
            let descriptions_str = match cstring_descriptions.to_str() {
                Ok(str) => str,
                Err(_) => "[]",
            };
            let cstring_functions = CString::from_raw(functions_ptr);
            let functions_str = match cstring_functions.to_str() {
                Ok(str) => str,
                Err(_) => "[]",
            };

            // parse json strings
            let descriptions: Vec<String> = serde_json::from_str(&descriptions_str)
                .expect("Failed to parse plugin descriptions");
            let functions: Vec<String> =
                serde_json::from_str(&functions_str).expect("Failed to parse plugin functions");

            Plugin {
                descriptions,
                functions,
                path,
            }
        }
    }

    pub fn load_native(path: &String) -> Library {
        unsafe { Library::new(path.to_owned()).expect("Failed to create library") }
    }

    pub fn load_wasm_plugin(path: &String) -> Plugin {
        let path = path.clone();

        // create instance of wasm plugin
        let instance = Self::load_wasm(&path);

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
        let descriptions: Vec<String> =
            serde_json::from_str(&descriptions_str).expect("Failed to parse plugin descriptions");
        let functions: Vec<String> =
            serde_json::from_str(&functions_str).expect("Failed to parse plugin functions");

        Plugin {
            descriptions,
            functions,
            path,
        }
    }

    pub fn load_wasm(path: &String) -> Instance {
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
        Instance::new(&module, &import_object).expect("Failed to create instance")
    }
}
