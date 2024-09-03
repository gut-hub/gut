use libloading::{Library, Symbol};
use std::ffi::CString;
use std::fs;
use std::os::raw::c_char;
use wasmer::{Instance, Memory, Module, Store, TypedFunction, Value, WasmPtr};
use wasmer_wasix::{WasiEnv, WasiFunctionEnv};

use crate::gut_lib;

pub struct WasmPlugin {
    instance: Instance,
    store: Store,
    wasi_env: WasiFunctionEnv,
}

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
                    // create wasm plugin
                    let wasi_plugin = Self::load_wasm(&plugin.path);

                    // get instance, store, and wasi env
                    let instance = wasi_plugin.instance;
                    let mut store = wasi_plugin.store;
                    let mut wasi_env = wasi_plugin.wasi_env;

                    // create memory of the wasm plugin
                    let memory: &Memory = instance
                        .exports
                        .get_memory("memory")
                        .expect("Failed to get memory");

                    // create runtime
                    let runtime = tokio::runtime::Builder::new_multi_thread()
                        .enable_all()
                        .build()
                        .expect("Failed to create tokio runtime");
                    let _guard = runtime.enter();

                    // initailize wasi env
                    wasi_env
                        .initialize(&mut store, instance.clone())
                        .expect("Failed to initialize wasi_env");

                    // create function definition
                    let lib_fn = instance
                        .exports
                        .get_function(&name)
                        .expect("Failed to get function");

                    // write the string argument into the lineary memory
                    let memory_view = memory.view(&store);
                    memory_view
                        .write(1, &argument.as_bytes())
                        .expect("Failed to write to memory");

                    // invoke function
                    lib_fn
                        .call(&mut store, &[Value::I32(argument.as_bytes().len() as i32)])
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

        // create wasm plugin
        let wasi_plugin = Self::load_wasm(&path);

        // get instance, store, and wasi env
        let instance = wasi_plugin.instance;
        let mut store = wasi_plugin.store;
        let mut wasi_env = wasi_plugin.wasi_env;

        // create memory
        let memory: &Memory = instance
            .exports
            .get_memory("memory")
            .expect("Failed to get memory");

        // create runtime
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to create tokio runtime");
        let _guard = runtime.enter();

        // initailize wasi env
        wasi_env
            .initialize(&mut store, instance.clone())
            .expect("Failed to initialize wasi_env");

        // define gut export functions
        let functions: TypedFunction<(), WasmPtr<u8>> = instance
            .exports
            .get_typed_function(&mut store, "gut_export_functions")
            .expect("Failed to define gut_export_functions");
        let descriptions: TypedFunction<(), WasmPtr<u8>> = instance
            .exports
            .get_typed_function(&mut store, "gut_export_descriptions")
            .expect("Failed to define gut_export_descriptions");

        // invoke gut export functions
        let functions_ptr: WasmPtr<u8> = functions
            .call(&mut store)
            .expect("Failed to call gut_export_functions");
        let descriptions_ptr: WasmPtr<u8> = descriptions
            .call(&mut store)
            .expect("Failed to call gut_export_descriptions");

        // get strings from memory
        let memory_view = memory.view(&store);
        let functions_str = functions_ptr
            .read_utf8_string_with_nul(&memory_view)
            .expect("Failed to get string from memory");
        let descriptions_str = descriptions_ptr
            .read_utf8_string_with_nul(&memory_view)
            .expect("Failed to get string from memory");

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

    pub fn load_wasm(path: &String) -> WasmPlugin {
        // create default store
        let mut store = Store::default();

        // create module from plugin path
        let module = Module::from_file(&store, &path).expect("Failed to load module");

        // create runtime
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to create tokio runtime");
        let _guard = runtime.enter();

        // create an environment
        let wasi_env = WasiEnv::builder("Gut")
            .finalize(&mut store)
            .expect("Failed to create wasi env");

        // create imports
        let import_object = wasi_env
            .import_object(&mut store, &module)
            .expect("Failed to create import object");

        // create instance of wasm plugin
        let instance =
            Instance::new(&mut store, &module, &import_object).expect("Failed to create instance");

        // wasi_env.on_exit(&mut store, None);
        WasmPlugin {
            instance,
            store,
            wasi_env,
        }
    }
}
