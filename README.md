![](/assets/app_main_screen.png)

Easy Auto Deploy was born from a critical need in development teams: technical knowledge concentrated in a few people creates an unacceptable operational risk. When the only developer who knows how to deploy the application is unavailable or leaves the company, entire projects can be paralyzed, and production outages become a daily occurrence.

This tool democratizes application deployment, transforming complex Docker and DevOps processes into accessible one-click experiences (although it can also be done via command line using the CLI). It's not about replacing developers, but about empowering the entire team—from managers to less technical colleagues—to keep systems running without depending on a single developer who has to rush in to save the day.

> [!IMPORTANT]
> This tool is not intended to be a replacement for developers, much less Docker (on the contrary, it exists thanks to Docker). If preferred, it is always recommended to use the native tool if you do not trust other solutions. At the end of the day, this project exists simply to facilitate development.

_All changes that are still in the development and testing phase are being made in: [develop](https://github.com/CatHood0/Easy-Auto-Deploy/tree/develop)_

# MAIN FEATURES I'M FOCUSED ON

- Functional MVP: Basic CLI working
- Complete Pipeline: Robust end-to-end deployment
- Operational GUI: Full graphical interface
- Extensible System: Plugins and integrations
- Production Ready: Complete testing and packaging

## ROADMAP

PHASE 1: THE VERY BASICS OF THE SYSTEM

1.1. EVENT AND PIPELINE SYSTEM

- Define event architecture
  - Create DeploymentEvent base class
  - Implement EventBus for communication between services
  - Define event types: PostInitEvent, PreCloneEvent, PostDeployEvent, etc.
  - Event subscription system
- Implement Deployment Pipeline
  - Create DeploymentPipeline abstract class
  - Define the 7 phases of the pipeline
  - Pre/post execution hooks system
  - Error handling and automatic rollback
- YAML configuration system
  - YAML file parser for configuration
  - Configuration schema validation
  - Configuration templates system
  - Merge configurations (base + environment)

1.2. CLI INFRASTRUCTURE

- CLI Framework Setup
  - Configure `args` package as a base
  - Create Command base class with helpers
  - Consistent logging system (colors, levels)
  - Unified and as user-friendly as possible error handling
- Core Project Commands
  - `project:create` with validations and interactive mode
  - `project:list` with table output and filters
  - `project:info` with detailed information
  - `project:delete` with confirmation
- Storage System
  - Save configurations in YAML
  - Encryption system for sensitive data (thinking about it)
  - Automatic backup of configurations (optional)
  - Configuration version migration (should I?)

PHASE 2: ROBUST DEPLOYMENT

2.1. IMPROVED DEPLOYMENT PIPELINE

- Implement the 7 complete phases
  - `post-app-init`: A phase that does nothing more than run every time the application starts
  - `pre-clone`: Verification of requirements
  - `clone`: Repository cloning
  - `post-clone`: Template processing
  - `pre-deploy`: Docker verifications
  - `deploy`: Execution of `docker-compose`
  - `post-deploy`: Health checks
  - `monitoring`: Continuous monitoring

2.2. CUSTOM COMMANDS SYSTEM

- Command Engine
  - Implement Command base class
  - Create commands: CreateCommand, MoveCommand, UpdateCommand, RenameCommand
  - System of variables and templates in commands
  - Ordering and dependencies between commands
- UI for Command Configuration
  - Visual pipeline editor
  - Drag & drop of deployment stages
  - Configuration of variables per command
  - Real-time validation

PHASE 3: GRAPHICAL INTERFACE

3.1. MAIN GUI

- Dashboard Screen
  - List of projects with statuses
  - Metrics of recent deployments
  - System status (Docker, resources)
  - Notifications and alerts
- Project Management
  - Create/edit projects with a form
  - Configuration of environment variables
  - Visualization of the deployment pipeline
  - Deployment history
- Real-Time Monitor
  - Log terminal with tracking
  - Real-time status of containers
  - Resource metrics (CPU, memory)
  - Push notification system

3.2. CLI-GUI INTEGRATION

- Bidirectional Communication
  - GUI executes CLI commands internally
  - CLI emits events for updates in the GUI
  - Shared state system
  - Configuration synchronization

🔧 PHASE 4: INTEGRATIONS SYSTEM

4.1. CORE INTEGRATIONS

- Modular Integrations System
  - `Integration` base class
  - Registration and discovery system
  - UI configuration for integrations
  - Lifecycle management of integrations
- Nginx Integration
  - Auto-configuration of reverse proxy
  - Automatic SSL config generation
  - Load balancing configuration
  - Endpoint health checks
- Integration of Easy-Docker and Easy-Docker-Compose (configure your projects without interacting with an IDE)
  - Client for Dockerfile LSP
  - Auto-completion in editors
  - Real-time validation
  - Automatic quick-fixes

PHASE 5: TESTING AND QUALITY

5.1. COMPREHENSIVE TESTING

- Unit Tests
  - Tests for all core services
  - Tests for CLI commands
  - Tests for configuration parsers
  - Mock external dependencies (Docker, Git)
- Integration Tests
  - Full pipeline tests
  - Real deployment tests in isolated containers
  - UI tests with golden files
  - Performance testing
- End-to-End Tests
  - Complete user flows
  - Cross-platform tests (Windows, Linux, macOS)
  - Error recovery tests
  - Load testing

5.2. CODE QUALITY

- Static Analysis
  - Configure linter (`dart analyze`)
  - Configure formatter (`dart format`)
  - Static code analysis
  - Quality metrics (coverage, complexity)
- Documentation
  - Technical documentation (architecture)
  - User documentation (guides)
  - API documentation (plugins)
  - Examples and tutorials

PHASE 6: PREPARATION FOR PRODUCTION

6.1. PACKAGING AND DISTRIBUTION

- Build and Packaging
  - Build scripts for all platforms
  - Installers (deb, rpm, msi, pkg)
  - Auto-update mechanism
  - Code signing for distributions

6.2. MONITORING AND LOGGING

- Observability
  - Structured logging (JSON)
  - System health checks
