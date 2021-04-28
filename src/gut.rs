use serde_json::json;
use serde_json::Value;

use std::fs::read_to_string;
use std::fs::File;

#[derive(Debug, Clone)]
pub struct GutConf {
    pub input_color: String,
}

pub fn create_empty_config() -> String {
    let empty_json = json!({});
    let file_name = format!("{}/gut.json", get_gut_dir());
    // create a scope to close the file after writing
    {
        // create config file
        let gut_config = File::create(&file_name).expect("Failed to create gut config");

        // write file
        serde_json::ser::to_writer(&gut_config, &empty_json).expect("Failed to write file");
    }

    empty_json.to_string()
}

pub fn get_gut_config() -> Value {
    let file_name = format!("{}/gut.json", get_gut_dir());
    let conf_str = read_to_string(file_name).expect("Failed to parse gut conf");
    let conf: Value = serde_json::from_str(&conf_str).expect("Failed to parse gut conf");

    conf
}

pub fn get_gut_dir() -> String {
    let home_dir = match dirs::home_dir() {
        Some(dir) => dir,
        None => panic!("Failed to find home directory"),
    };

    let home = match home_dir.to_str() {
        Some(dir) => dir.to_string(),
        None => panic!("Failed to convert home directory to string"),
    };

    format!("{}/{}", home, ".gut")
}
