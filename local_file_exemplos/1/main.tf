resource local_file "criando_arquivo" {
  filename             = "primeiro_arqurivo_tf.txt"
  content              = "Aprendendo terraform linguagem hcl - Alterado"
  file_permission      = 0777
  directory_permission = 0777
}
 