# 🚀 Demoblaze API Automation Challenge

Suite de automatización para validar los servicios de autenticación de la plataforma Demoblaze utilizando **Karate DSL**, **JUnit 5** y **Maven**.

El proyecto fue diseñado siguiendo principios de **QA Automation**, priorizando:

* Mantenibilidad
* Escalabilidad
* Reutilización
* Independencia de datos
* Ejecuciones reproducibles

---

<p align="center">

![Karate DSL](https://img.shields.io/badge/Karate%20DSL-v1.5.2-6f42c1?style=for-the-badge)

![Java](https://img.shields.io/badge/Java-17-ED8B00?style=for-the-badge\&logo=openjdk)

![JUnit](https://img.shields.io/badge/JUnit-5-25A162?style=for-the-badge\&logo=junit5)

![Maven](https://img.shields.io/badge/Maven-3.8+-C71A36?style=for-the-badge\&logo=apachemaven)

</p>

---

# 📖 Descripción

Este proyecto automatiza la validación de los endpoints:

```http
POST /signup
POST /login
```

de la API pública de Demoblaze:

```text
https://api.demoblaze.com
```

La suite valida tanto flujos exitosos como escenarios negativos, incluyendo:

* Registro de usuarios
* Detección de duplicados
* Inicio de sesión exitoso
* Contraseñas incorrectas
* Usuarios inexistentes
* Validación de tokens
* Escenarios parametrizados mediante tablas de datos

---

# 🎯 Objetivos

✅ Verificar el comportamiento funcional de Signup.

✅ Verificar el comportamiento funcional de Login.

✅ Detectar respuestas inconsistentes.

✅ Validar contratos de respuesta mediante schemas.

✅ Garantizar independencia entre escenarios.

✅ Generar evidencia automática mediante reportes HTML.

---

# 🛠 Stack Tecnológico

| Tecnología       | Uso                     |
| ---------------- | ----------------------- |
| Karate DSL 1.5.2 | Automatización de APIs  |
| Java 17          | Runtime                 |
| Maven            | Gestión de dependencias |
| JUnit 5          | Ejecución               |
| Git              | Control de versiones    |

---

# 📂 Estructura del Proyecto

```text
karate-main
│
├── pom.xml
├── README.md
├── readme.txt
├── CONCLUSIONES.md
│
└── src
    └── test
        ├── java
        │
        ├── api
        │   └── demoblaze
        │       ├── signup.feature
        │       └── login.feature
        │
        ├── common
        │   ├── payloads
        │   │   ├── login-valid.json
        │   │   └── login-invalid.json
        │   │
        │   └── schemas
        │       ├── signup-success-response.json
        │       ├── signup-error-response.json
        │       ├── login-success-response.json
        │       └── login-error-response.json
        │
        ├── helpers
        │   └── assert-token.feature
        │
        ├── runners
        │   ├── ChallengeTest.java
        │   └── SmokeTest.java
        │
        └── karate-config.js
```

---

# ⚙️ Arquitectura de Automatización

La solución fue diseñada bajo una arquitectura desacoplada:

### Features

Contienen la lógica de negocio de los escenarios.

```text
signup.feature
login.feature
```

### Payloads

Centralizan los cuerpos de solicitud.

```text
common/payloads
```

### Schemas

Permiten validar contratos de respuesta.

```text
common/schemas
```

### Helpers

Componentes reutilizables.

```text
helpers/assert-token.feature
```

### Configuración Global

Variables compartidas entre todos los escenarios.

```text
karate-config.js
```

---

# 📋 Requisitos Previos

## Java

```bash
java -version
```

Resultado esperado:

```text
Java 17+
```

---

## Maven

```bash
mvn -version
```

Resultado esperado:

```text
Apache Maven 3.8+
```

---

# 🚀 Instalación

## Clonar repositorio

```bash
git clone https://github.com/lunakenya/karate.git
```

```bash
cd karate
```

---

# ▶️ Ejecución

## Ejecutar toda la suite

```bash
mvn clean test
```

---

## Ejecutar únicamente Smoke Tests

```bash
mvn test -Dkarate.options="--tags @smoke"
```

---

## Ejecutar únicamente Login

```bash
mvn test -Dkarate.options="--tags @login"
```

---

## Ejecutar únicamente Signup

```bash
mvn test -Dkarate.options="--tags @signup"
```

---

## Ejecutar Regresión

```bash
mvn test -Dkarate.options="--tags @regression"
```

---

# 📊 Cobertura de Pruebas

## Signup

| ID     | Escenario                         |
| ------ | --------------------------------- |
| TC-001 | Crear usuario dinámico            |
| TC-002 | Usuario duplicado                 |
| TC-003 | Usuario dinámico mediante Outline |
| TC-004 | Usuario preexistente              |

---

## Login

| ID     | Escenario                            |
| ------ | ------------------------------------ |
| TC-005 | Login exitoso                        |
| TC-006 | Password incorrecto                  |
| TC-007 | Usuario inexistente                  |
| TC-008 | Login válido mediante Outline        |
| TC-009 | Password incorrecto mediante Outline |
| TC-010 | Usuario inexistente mediante Outline |

---

# 🔍 Estrategias Implementadas

## Usuarios Dinámicos

Para evitar dependencia de datos existentes:

```javascript
var timestamp = System.currentTimeMillis()
```

Generando usuarios como:

```text
user_1752791999999
```

---

## Validación por Schemas

Ejemplo:

```karate
And match response == schema
```

Permite verificar estructura y contrato sin depender de valores específicos.

---

## Scenario Outline

Uso de tablas de datos para maximizar cobertura.

```karate
Scenario Outline:
Examples:
  | read('classpath:common/payloads/login-data.csv') |
```

Beneficios:

* Menos duplicación
* Mayor mantenibilidad
* Fácil ampliación

---

# ⚠️ Hallazgo Importante de la API

Durante la automatización se identificó que Demoblaze utiliza un patrón poco convencional:

## Todos los escenarios retornan HTTP 200

Incluso para errores de negocio:

```json
{
  "errorMessage": "Wrong password."
}
```

o

```json
{
  "errorMessage": "User does not exist."
}
```

Por lo tanto:

> Un HTTP 200 NO garantiza una operación exitosa.

La validación debe realizarse inspeccionando el payload de respuesta.

---

# 🔐 Comportamiento del Token

La API devuelve:

```text
Auth_token: xxxxxxxxxxx
```

El token:

* No es JWT
* No posee firma verificable
* Parece construirse a partir del usuario y timestamp

Por esta razón se implementó una validación específica:

```text
helpers/assert-token.feature
```

---

# 📈 Reportes

Karate genera reportes HTML automáticamente.

Ubicación:

```text
target/surefire-reports/karate-reports/
```

Reporte principal:

```text
target/surefire-reports/karate-reports/karate-summary.html
```

---

# 📷 Información Disponible en los Reportes

* Tiempo de respuesta
* Headers
* Request Payload
* Response Payload
* Resultado por escenario
* Logs de ejecución
* Evidencia completa

---

# 🧪 Resultado Esperado

```text
[INFO] Tests run: 10
[INFO] Failures: 0
[INFO] Errors: 0
[INFO] BUILD SUCCESS
```

---

# 🧠 Conclusiones

La solución implementada demuestra:

* Automatización desacoplada
* Uso correcto de Karate DSL
* Cobertura positiva y negativa
* Datos autónomos
* Validación de contratos
* Escalabilidad para futuras APIs

Para el análisis completo consulte:

```text
CONCLUSIONES.md
```

---

# 👨‍💻 Autor

**Luna Kenya**
---
