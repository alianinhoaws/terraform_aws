variable "vpc" {
  description = "main vpc"
}

variable "entrypoint" {
  default = "exports.handler"
  description = "func name to execute by lambda"
}
variable "file_path" {
  description = "path to lambda code"
}