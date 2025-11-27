# Estonian eID OpenID Connect (OIDC) Provider - Mobile-ID, Smart-ID, ID-Card Authentication

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Java](https://img.shields.io/badge/Java-21-blue.svg)](https://openjdk.java.net/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-green.svg)](https://spring.io/projects/spring-boot)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

Open-source OpenID Connect authentication system for Estonian electronic identification (eID). Supports **Mobile-ID**, **Smart-ID**, and **ID-Card** authentication methods with OAuth2/OIDC standard compliance.

**Keywords:** Estonian eID, Mobile-ID integration, Smart-ID authentication, ID-Card login, OIDC provider, OAuth2 server, Spring Boot authentication, Estonian digital identity, e-government authentication

## ✨ Features

- ✅ **Mobile-ID Authentication** - SMS-based two-factor authentication for Estonian, Latvian, and Lithuanian users
- ✅ **Smart-ID Authentication** - App-based authentication with biometrics support
- ✅ **ID-Card Authentication** - PKI-based authentication using Estonian ID-Card with Web eID
- ✅ **OAuth2/OIDC Compliant** - Standard-compliant authorization server with JWT tokens
- ✅ **Spring Boot 3** - Modern Java framework with Spring Security integration
- ✅ **Redis Session Storage** - Scalable session management
- ✅ **Docker Ready** - Complete Docker Compose setup for easy deployment
- ✅ **Mock Services** - Development-friendly mock APIs for testing without real eID services
- ✅ **React UI** - Modern, responsive authentication interface

## 🏗️ Architecture

The system consists of multiple components linked as Git submodules:

- **[eid-oidc-provider](https://github.com/jetcar/eid-oidc-provider)** - OIDC Provider (Spring Boot 3.2.5, Java 21)
  - Implements OAuth2/OIDC authorization server
  - Supports ID-Card, Mobile-ID, and Smart-ID authentication
  - Issues JWT tokens and manages user sessions

- **[oidc-test](https://github.com/jetcar/oidc-test)** - Test client application (Spring Boot 3.2.5, Java 17)
  - Demo OAuth2 client using Spring Security
  - Demonstrates full OIDC authentication flow
  - Thymeleaf-based UI

- **[eid-mock](https://github.com/jetcar/eid-mock)** - Mock eID API server (Spring Boot 3.2.5, Java 17)
  - Mock implementation of Smart-ID and Mobile-ID APIs
  - Used for development and testing without real eID services
  - Auto-completes authentication sessions with random delays

- **[eid-auth-ui](https://github.com/jetcar/eid-auth-ui)** - React authentication UI
  - Modern React-based authentication interface
  - Supports all three eID methods
  - Embedded in eid-oidc-provider static resources

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Java 21 (for eid-oidc-provider)
- Java 17 (for oidc-test and eid-mock)
- Maven 3.9+
- Node.js 18+ (for eid-auth-ui development)

### Clone with Submodules

```bash
git clone --recurse-submodules https://github.com/jetcar/eid-openidc.git
cd eid-openidc
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

### Quick Start with Docker

```bash
docker-compose up --build
```

This starts all services:
- **HAProxy**: https://localhost (reverse proxy)
- **eid-oidc-provider**: https://localhost/eid-oidc-provider or https://localhost:8443
- **oidc-test**: https://localhost/oidc-test or https://localhost:8082
- **eid-mock**: https://localhost:8083
- **Redis**: localhost:6379

### Development

#### Build All Projects

```bash
mvn clean install
```

#### Build Individual Projects

```bash
cd eid-oidc-provider
mvn clean install

cd oidc-test
mvn clean install

cd eid-mock
mvn clean install
```

#### Build Frontend

```bash
cd eid-auth-ui
npm install
npm run build
node copy-build-to-backend.js
```

## Architecture Details

### Virtual Path Routing

HAProxy provides virtual path routing:
- `/eid-oidc-provider/*` → eid-oidc-provider:8443
- `/oidc-test/*` → oidc-test:8082
- `/*` → eid-auth-ui (static files)

The OIDC provider uses forwarded headers (`X-Forwarded-Proto`, `X-Forwarded-Host`, `X-Forwarded-Prefix`) to construct dynamic URLs.

### Authentication Flows

#### Mobile-ID
1. POST `/mobileid/start` → returns `sessionId`, `verificationCode`
2. Poll GET `/mobileid/check?sessionId=...` until complete
3. Exchange authorization code for tokens at `/token`

#### Smart-ID
1. POST `/smartid/start` → returns `sessionId`, `verificationCode`
2. Poll GET `/smartid/check?sessionId=...` until complete
3. Exchange authorization code for tokens at `/token`

#### ID-Card
1. GET `/idlogin/challenge` → returns nonce
2. POST `/idlogin/login` with certificate and signature
3. Exchange authorization code for tokens at `/token`

### Session Storage

Redis is used for session storage with TTL-based expiration:
- Authorization codes
- Mobile-ID/Smart-ID sessions
- Access tokens and refresh tokens

## API Documentation

Swagger UI is available for all Java services:
- **eid-oidc-provider**: https://localhost:8443/swagger-ui.html
- **oidc-test**: https://localhost:8082/swagger-ui.html
- **eid-mock**: https://localhost:8083/swagger-ui.html

## Configuration

### OIDC Clients

Edit `eid-oidc-provider/config/oidc-clients.json` to add/modify OIDC clients.

### SSL Certificates

Generate keystores using the provided scripts:
```powershell
cd eid-oidc-provider
.\generate-keystore.ps1

cd oidc-test
.\generate-keystore.ps1

cd eid-mock
.\generate-keystore.ps1
```

### Environment Variables

Configure via `docker-compose.yml` or application.yml files in each project.

## Testing

### Manual Testing
1. Navigate to https://localhost
2. Click "Authorize" to start OIDC flow
3. Select authentication method (Mobile-ID, Smart-ID, or ID-Card)
4. Complete authentication
5. View token response and userinfo

### Using Mock Services

The eid-mock service automatically completes authentication after a random delay (5-60 seconds). Use any Estonian personal code format: `PNOEE-12345678901`

## Port Mapping

- **80/443**: HAProxy (virtual paths)
- **8443**: eid-oidc-provider (direct access)
- **8082**: oidc-test (direct access)
- **8083**: eid-mock (direct access)
- **6379**: Redis
- **5005**: eid-oidc-provider remote debugging
- **5006**: oidc-test remote debugging
- **5007**: eid-mock remote debugging

## Debugging

VS Code launch configurations are provided in `.vscode/launch.json` for all services.

## Contributing

Each component is maintained in its own repository. See individual repositories for contribution guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Resources

- [OIDC Provider README](eid-oidc-provider/README.md)
- [OIDC Test Client README](oidc-test/README.md)
- [Auth UI README](eid-auth-ui/README.md)
- [Smart-ID Documentation](https://github.com/SK-EID/smart-id-documentation)
- [Mobile-ID Documentation](https://github.com/SK-EID/MID)
