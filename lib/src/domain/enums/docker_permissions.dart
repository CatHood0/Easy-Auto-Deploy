/// Estados posibles de los permisos de Docker
enum DockerPermissionStatus {
  valid, // Todo funciona correctamente
  notInstalled, // Docker no está instalado
  notInstalledCompose, // Docker compose no está instalado
  notServiceInstalled, // Algún servicio requerido no está instalado
  notRunningDocker, // 
  noPermission, // No hay permisos para usar Docker
  unknownError, // Error desconocido
}
