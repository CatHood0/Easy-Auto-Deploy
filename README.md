# Easy Docker Deployment (alpha phase) 

![](/assets/app_main_screen.png)

**Simplifica el despliegue de imagenes de Docker con una interfaz intuitiva en Flutter**

> [!IMPORTANT]
> En este momento me encuentro centrado en la creación de una versión CLI para esta aplicación, que mejore la compatibilidad entre Windows y Mac)

## 📖 Tabla de Contenidos

- [Características](#-características)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Instalación](#-instalación)
- [Guía de Uso](#-guía-de-uso)
- [Solución de Problemas](#-solución-de-problemas)
- [Desarrollo](#-desarrollo)

## ✨ Características

### 🔄 Gestión de Repositorios
<!-- - **Clonación automática** de repositorios Git -->
<!-- - **Soporte para autenticación** (usuario/token) -->
<!-- - **Selección de ramas** específicas -->

### 🐳 Gestión de Contenedores
<!-- - **Despliegue automático** con Docker Compose -->
<!-- - **Monitoreo en tiempo real** de logs -->
<!-- - **Gestión de estado** (iniciar/detener/verificar) -->
<!-- - **Verificación automática** de permisos y dependencias -->

### 🛡️ Sistema de Configuración Segura
<!-- - **Interfaz intuitiva** para variables de entorno -->
<!-- - **Procesamiento de variables de entorno y comandos** de configuración -->
<!-- - **Almacenamiento seguro** de credenciales sensibles (falta implementación de encriptación datos) -->
<!-- - **Validación automática** de configuraciones requeridas -->

### 🔍 Diagnóstico Inteligente
<!-- - **Verificación automática** de requisitos del sistema -->
<!-- - **Verificación de conectividad** de red -->
<!-- - **Sistema de mensajes de error** contextuales -->
<!-- - **Detección de conflictos** de puertos -->
<!-- - **Monitoreo de espacio** en disco -->

## ⚙️ Requisitos del Sistema

### Requisitos Obligatorios
- **Docker** ≥ 20.0
- **Docker Compose** ≥ 2.0
- **Git** ≥ 2.0
- **Sistema operativo**: Linux (Testeado solo en Zorin 18). Actualmente no tenemos soporte para Windows o Mac aún. 


### Permisos Requeridos
```bash
# Agregar usuario al grupo docker (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalación
docker --version
docker-compose --version
git --version
```

## 🚀 Instalación

### 1. Descargar la Aplicación
Visita [releases](https://github.com/CatHood0/auto-deployment/releases) y descarga la versión para tu sistema operativo.

## 📖 Guía de Uso

### 🔄 Flujo Básico de Despliegue

#### 1. Clonar un Repositorio
```
📥 Clonación → ⚙️ Configuración → 🐳 Despliegue → 📊 Monitoreo
```

#### 2. Configurar Variables de Entorno

**Variables típicas:**
- Credenciales de base de datos
- API Keys de servicios externos
- Configuraciones de conexión
- Secretos de aplicación

#### 3. Configurar los comandos 



#### 4. Monitorear el Despliegue
- **Logs en tiempo real**
- **Estado de contenedores**
- **Uso de recursos**
- **Errores y advertencias**

## 🛠️ Solución de Problemas

### 🔍 Problemas Comunes y Soluciones

#### ❌ "Permisos de Docker insuficientes"
```bash
# Solución:
sudo usermod -aG docker $USER
newgrp docker

# Si el grupo docker no existe:
sudo groupadd docker
sudo systemctl restart docker
```

#### ❌ "Docker no está ejecutándose"
```bash
# Solución:
sudo systemctl start docker
sudo systemctl enable docker
```

#### ❌ "Error de clonación Git"
- Verificar credenciales de acceso
- Comprobar conexión a internet
- Validar URL del repositorio

#### ❌ "Conflicto de puertos"

_Aún no implementamos correctamente el manejo de este tipo casos_

```bash
# Verificar puertos en uso:
sudo lsof -i :8080

# Liberar puerto:
sudo kill -9 $(sudo lsof -t -i:8080)
```

#### ❌ "Espacio en disco insuficiente"

_Aún no implementamos correctamente el manejo de estos tipo de casos_

```bash
# Limpiar Docker:
docker system prune -a

# Ver espacio:
df -h
```

### 📋 Verificación del Sistema

La aplicación incluye un **diagnóstico automático** que verifica:

- ✅ Conexión con Docker Daemon
- ✅ Permisos de usuario
- ✅ Conectividad de red
<!-- - ✅ Espacio en disco disponible -->
<!-- - ✅ Conflictos de puertos -->
<!-- - ✅ Dependencias del sistema -->

### 🏗️ Arquitectura de Servicios

| Servicio | Función |
|----------|---------|
| **DockerService** | Gestión principal de contenedores |
| **CommandExecuter** | Gestiona todas las tareas relacionadas con los comandos |
| **GitInstallationChecker** | Verificación de Git |
| **NetworkIssueResolver** | Diagnóstico de conectividad |
| **PortConflictResolver** | Gestión de conflictos de puertos |

## 🔧 Desarrollo

### 🚀 Despliegue de la Aplicación

```bash
# Desarrollo
flutter run -d <linux>

# Build para producción
flutter build linux  

# Ejecutar tests
flutter test
```

## 🤝 Contribución

### Reportar Problemas
1. Verificar que el problema no esté ya reportado
2. Incluir logs de error y pasos para reproducir
3. Especificar sistema operativo y versión (aunque solo manejamos Linux aún)

### Sugerir Mejoras
1. Describir el caso de uso
2. Proponer implementación
3. Incluir ejemplos si es posible

## 🆘 Soporte

### Documentación Adicional
- [Guía de Docker](https://docs.docker.com/)
- [Documentación de Flutter](https://flutter.dev/docs)

<!-- ### Comunidad -->
<!-- - 📧 Email: soporte@autodeployment.com -->
<!-- - 💬 Discord: [Enlace al servidor] -->
<!-- - 🐛 Issues: [GitHub Issues] -->

<!-- **¿Listo para simplificar tus despliegues?** 🎉 -->

<!-- [Descargar última versión] | [Ver demostración] | [Reportar problema] -->
