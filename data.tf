data "archive_file" "app_zip" {
  type        = "zip"
  source_dir  = "./"
  output_path = "./app.zip"

  excludes = [
    ".terraform",
    ".git",
    ".gitignore",
    "README.md",
    "test",
    "app.zip",
    "node_modules_layer.zip",
    "node_modules",
  ]
}
