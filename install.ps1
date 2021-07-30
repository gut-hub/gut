# Vars
$GUT_DIR = "${HOME}\.gut"
$GUT_FILE = "gut.exe"
$GUT_PATH = "${GUT_DIR}\${GUT_FILE}"

# Create gut directory
If (-NOT (Test-Path -Path ${GUT_DIR})) {
  Write-Output "Creating directory: ${GUT_DIR}"
  New-Item -Path ${GUT_DIR} -ItemType "directory"
}

# Get latest release
Write-Output "Getting latest release"
$release = Invoke-RestMethod -URI https://api.github.com/repos/gut-hub/gut/releases/latest
$version = ${release}.tag_name
$url = Write-Output ${release}.assets.browser_download_url | Select-String -Pattern $GUT_FILE

# Download
Write-Output "Downloading: ${url}"
Invoke-WebRequest -Uri "${url}" -OutFile "${GUT_DIR}\${GUT_FILE}"
Write-Output  "Download complete: ${GUT_DIR}\${GUT_FILE}"

# Add binary to PATH
$oldpath = [System.Environment]::GetEnvironmentVariable('PATH','machine')
$newpath = "$oldpath;${GUT_DIR}\;"

If (-NOT ($oldpath -like ${GUT_DIR})) {
  Write-Output "Adding gut to PATH"
  Write-Output "Please open a new terminal"
  [Environment]::SetEnvironmentVariable("PATH", "$newpath", [EnvironmentVariableTarget]::Machine)
}
