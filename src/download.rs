use serde_json::Value;
use std::fs;

pub fn get_plugins() -> Vec<Value> {
  let res =
    reqwest::blocking::get("https://raw.githubusercontent.com/gut-hub/plugins/main/plugins.json")
      .expect("Failed to get plugins")
      .text()
      .expect("Failed to get plugins text");

  let data: Value = serde_json::from_str(&res).expect("Failed to parse plugin");

  let plugins = data["plugins"]
    .as_array()
    .expect("Failed to convert into array");

  plugins.clone()
}

pub fn download_gut(file_name: String) {
  // create download url
  let download_url = format!(
    "https://github.com/gut-hub/gut/releases/download/latest/{}",
    file_name
  );

  let mut gut_file = file_name.clone();
  if file_name.contains("-") {
    gut_file = "gut".to_string();
  }

  // create file name
  let file_path = format!("{}/{}", gut_lib::dir::get_gut_dir(), gut_file);

  // download the file
  println!("Downloading: {}", file_name);
  let res = reqwest::blocking::get(download_url).expect("Failed to download plugins");
  let data = res.bytes().expect("Failed to get plugin bytes");

  // write the file
  fs::write(&file_path, &data).expect("[CONF] Failed to write jinx_conf");
}

pub fn download_plugin(repo: String, release: String, file_name: String) {
  // create download url
  let download_url = format!("{}/releases/download/{}/{}", repo, release, file_name);

  // create file name
  let file_path = format!("{}/{}", gut_lib::dir::get_gut_dir(), file_name);

  // download the file
  println!("Downloading: {}", file_name);
  let res = reqwest::blocking::get(download_url).expect("Failed to download plugins");
  let data = res.bytes().expect("Failed to get plugin bytes");

  // write the file
  fs::write(&file_path, &data).expect("[CONF] Failed to write jinx_conf");
}
