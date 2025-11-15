import 'package:auto_deployment/src/data/services/services.dart';
import 'package:auto_deployment/src/domain/services/required_services.dart';

import '../git/git_clone_resolver.dart';
import '../git/git_installation_checker.dart';
import '../git/network_error.dart';
import 'docker_image_verifier.dart';

class DockerIssues extends RequiredServices<String, String> {
  const DockerIssues._();

  static const DockerIssues instance = DockerIssues._();

  @override
  String get serviceKey => 'docker-issues-resolver';

  @override
  Future<String> check(
    String provider, {
    void Function(String p1)? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async =>
      _messages[provider]!;

  static final Map<String, String> _messages = {
    'validation-error': '''
    # ❌ Datos inválidos
      Verifica que todos los campos estén completos y tengan formato correcto.
    ''',
    'Docker-Daemon': '''
# 🐳 Docker no está ejecutándose
**Solución rápida:**
```bash
sudo systemctl start docker
```

Si dicho comando devuelve un error, verifica en su sitio web:
[Guía completa](https://docs.docker.com/engine/install/)
''',
    'docker-permissions': '''
# 🔐 Sin permisos de Docker
**Solución:**
```bash
sudo usermod -aG docker \$USER
newgrp docker
```

> En caso de ejecutar `usermod` y recibir un error debido a "docker" ejecuta
> `sudo groupadd docker` (si tienes el servicio de docker corriendo ya 
> reinicialo: `sudo systemctl restart docker`)


[Ver guía completa](https://docs.docker.com/engine/install/linux-postinstall/)
''',
    DockerImageVerifier.instance.serviceKey: '''
# 📦 Imagen no encontrada
- Por favor, asegurate de que la imagen configurada
  en el repositorio, es la misma que está 
  en el `docker-compose.yaml`
''',
    '${DockerInstallationChecker.instance.serviceKey}-compose': '''
# 🐙 Docker Compose no instalado
[Guía de instalación](https://docs.docker.com/compose/install/)
''',
    DockerInstallationChecker.instance.serviceKey: '''
# 🔧 Docker no instalado
[Guía de instalación](https://docs.docker.com/engine/install/)
''',
    GitInstallationChecker.instance.serviceKey: '''
# 🔧 Git no instalado
**Solución:**
```bash
### Ubuntu/Debian:
sudo apt install git

### macOS:
brew install git
```

### Windows
[Descargar Git](https://git-scm.com/downloads)
''',
    GitCloneIssueResolver.instance.serviceKey: '''
# 📥 Error al clonar repositorio
**Soluciones:**
- Verifica la URL del repositorio
- Confirma tus credenciales de acceso
- Ejecuta: `git clone https://usuario:token@url-repositorio`
''',
    NetworkIssueResolver.instance.serviceKey: '''
# 🌐 Error de conexión
**Verifica:**
- Tu conexión a internet
- Firewalls/proxies corporativos
- Acceso al registry de Docker
''',
//     'port-conflict': '''
// # 🔌 Puerto en uso
// **Solución:**
// - Cambia el puerto en docker-compose.yml
// - O libera el puerto: `sudo lsof -ti:8080 | xargs kill -9`
// ''',
    'build-failed': '''
# 🛠️ Error en construcción
**Verifica:**
- Que el Dockerfile existe y es válido
- Que el docker-compose.yaml existe y es válido
- Las dependencias en el proyecto
''',
  };
}
