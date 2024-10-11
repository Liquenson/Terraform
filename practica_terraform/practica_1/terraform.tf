resource "local_file" "productos" {
  content  = "lista de productos nuevo mes"
  filename = "productos.txt"

}