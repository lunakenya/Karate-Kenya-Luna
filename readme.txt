================================================================================
  RETO TÉCNICO: Automatización API Demoblaze con Karate 
  readme.txt 
================================================================================

DESCRIPCIÓN
-----------
Proyecto de automatización de pruebas API para los endpoints de autenticación
de Demoblaze (https://api.demoblaze.com) usando Karate DSL, JUnit 5 y Maven.

Endpoints automatizados:
  POST /signup  → Registro de usuario
  POST /login   → Autenticación de usuario

================================================================================
STACK TECNOLÓGICO
================================================================================

  Java          : 17
  Maven         : 3.8+
  Karate DSL    : 1.5.2  (io.karatelabs)
  JUnit         : 5.10.1
  Logback       : 1.4.14

================================================================================
ESTRUCTURA DEL PROYECTO
================================================================================

demoblaze-karate-api/
├── pom.xml                                      ← Dependencias Maven
├── readme.txt                                   ← Este archivo
├── conclusiones.txt                             ← Hallazgos técnicos
└── src/test/
    ├── java/
    │   ├── karate-config.js                     ← Config global: baseUrl, testUser, testPassword
    │   ├── api/demoblaze/
    │   │   ├── signup.feature                   ← TC-001 a TC-004 (signup)
    │   │   └── login.feature                    ← TC-005 a TC-010 (login)
    │   ├── common/
    │   │   ├── payloads/
    │   │   │   ├── login-valid.json             ← Payload login exitoso (usa #(testUser))
    │   │   │   └── login-invalid.json           ← Payload login incorrecto (usa #(testUser))
    │   │   │                                    (signup-existing.json eliminado: TC-002 es autónomo)
    │   │   └── schemas/
    │   │       ├── signup-success-response.json ← Schema signup OK: "#string"
    │   │       ├── signup-error-response.json   ← Schema signup error: {errorMessage: "#string"}
    │   │       ├── login-success-response.json  ← Schema login OK: "#string"
    │   │       └── login-error-response.json    ← Schema login error: {errorMessage: "#string"}
    │   ├── helpers/
    │   │   └── assert-token.feature             ← Helper: valida prefijo Auth_token
    │   └── runners/
    │       ├── ChallengeTest.java               ← Suite completa (todos los casos)
    │       └── SmokeTest.java                   ← Suite smoke (@smoke: TC-001, TC-005)
    └── resources/
        └── logback-test.xml                     ← Configuración de logging

================================================================================
CASOS DE PRUEBA CUBIERTOS
================================================================================

SIGNUP (signup.feature):
  TC-001  @smoke @critical   Crear usuario nuevo (username dinámico con timestamp)
  TC-002  @regression @neg   Signup duplicado autónomo: crea usuario → intenta duplicar
                             → "This user already exist." | NO requiere datos preexistentes
  TC-003  @regression (OL)   Scenario Outline: nuevo usuario dinámico → éxito
  TC-004  @regression (OL)   Scenario Outline: usuario preexistente (testUser) → error

LOGIN (login.feature):
  TC-005  @smoke @critical   Login válido → token "Auth_token: ..."
  TC-006  @regression @neg   Login con password incorrecto → "Wrong password."
  TC-007  @regression @neg   Login con usuario inexistente → "User does not exist."
  TC-008  @regression (OL)   Scenario Outline: login válido (testUser)
  TC-009  @regression (OL)   Scenario Outline: password incorrecto (testUser)
  TC-010  @regression (OL)   Scenario Outline: usuario inexistente

OL = Scenario Outline | neg = @negative

TOTAL: 10 escenarios | 4 obligatorios del reto cubiertos explícitamente

NOTA: El reto solicitaba 4 casos obligatorios. Este proyecto incluye 10 escenarios
(6 adicionales) para mayor cobertura: Scenario Outlines, caso de usuario inexistente
en login y variantes del Outline que cubren los 3 comportamientos posibles del endpoint.

================================================================================
PRE-REQUISITOS
================================================================================

1. Java 17 instalado y en PATH
   Verificar: java -version   → openjdk 17.x.x

2. Maven 3.8+ instalado y en PATH
   Verificar: mvn -version    → Apache Maven 3.8.x

3. Conexión a Internet
   La API https://api.demoblaze.com debe ser accesible.

4. Usuario preexistente en Demoblaze (solo para TC-004, TC-005, TC-006, y Outlines)
   El usuario "test_existing_usr" es el valor por defecto de testUser en karate-config.js.
   Se usa en los escenarios de login válido y en el Outline TC-004 de signup.

   IMPORTANTE: TC-001 y TC-002 (casos obligatorios del reto) son completamente
   autónomos y NO requieren ningún usuario preexistente. Generan sus propios
   usuarios dinámicos con timestamp en cada ejecución.

   Si el usuario test_existing_usr no existe, se puede:
   a) Crear manualmente:
      curl -X POST https://api.demoblaze.com/signup \
        -H "Content-Type: application/json" \
        -d '{"username":"test_existing_usr","password":"Test@1234!"}'

   b) O sobreescribir con un usuario que sí exista:
      mvn test -DtestUser=mi_usuario -DtestPassword=mi_password

================================================================================
INSTRUCCIONES DE EJECUCIÓN PASO A PASO
================================================================================

PASO 1 — Posicionarse en el directorio del proyecto
  cd demoblaze-karate-api

PASO 2 — Resolver dependencias Maven (primera vez)
  mvn dependency:resolve -q

PASO 3 — EJECUTAR SUITE COMPLETA (todos los casos)
  mvn test
  o bien:
  mvn test -Dtest=ChallengeTest

  Resultado esperado: Tests run: 10, Failures: 0, BUILD SUCCESS

PASO 4 — EJECUTAR SUITE SMOKE (solo casos críticos)
  mvn test -Dtest=SmokeTest

  Resultado esperado: Tests run: 2, Failures: 0, BUILD SUCCESS
  Escenarios: TC-001 (signup) + TC-005 (login)

PASO 5 — EJECUTAR CON AMBIENTE ESPECÍFICO
  mvn test -Dkarate.env=qa

PASO 6 — SOBREESCRIBIR USUARIO DE PRUEBA DESDE LÍNEA DE COMANDOS
  mvn test -DtestUser=mi_usuario -DtestPassword=mi_password

  Esto sobreescribe las variables testUser y testPassword definidas en
  karate-config.js sin necesidad de modificar archivos de código.

PASO 7 — VER REPORTE HTML
  Abrir en el navegador:
    target/surefire-reports/karate-reports/karate-summary.html
    target/surefire-reports/karate-reports/api.demoblaze.signup.html
    target/surefire-reports/karate-reports/api.demoblaze.login.html
    target/surefire-reports/karate-reports/karate-timeline.html

================================================================================
HALLAZGOS IMPORTANTES DE LA API
================================================================================

1. La API siempre retorna HTTP 200, incluso en errores funcionales.
   → NO asumir que 200 significa éxito.
   → Los errores se detectan validando el campo "errorMessage" en el body.

2. Signup exitoso retorna un string JSON vacío: ""
   → No es null, no es un objeto. Es un string con valor vacío.
   → El schema correcto es "#string" (marcador Karate).

3. Login exitoso retorna un string plano (no JSON):
   → "Auth_token: dGVzdF9leGlzdGluZ191c3IxNzgxNjYy"
   → El token NO es JWT estándar. Es el username en Base64 + timestamp.

4. Login distingue dos tipos de error:
   → Password incorrecto:   {"errorMessage": "Wrong password."}
   → Usuario no existente:  {"errorMessage": "User does not exist."}

================================================================================
CÓMO REPRODUCIR EL RETO DESDE CERO
================================================================================

1. Clonar o descomprimir el proyecto en una máquina con Java 17 y Maven.
https://github.com/lunakenya/karate.git
2. Ejecutar directamente: mvn test
   → TC-001 y TC-002 son autónomos y no requieren setup previo.
   → TC-005/006/007 usan el usuario por defecto (test_existing_usr).
   → Si el usuario por defecto no existe: mvn test -DtestUser=u -DtestPassword=p
3. Verificar: BUILD SUCCESS con 10/10 escenarios pasando.
4. Abrir el reporte en:
   target/surefire-reports/karate-reports/karate-summary.html

================================================================================
SOLUCIÓN DE PROBLEMAS
================================================================================

BUILD FAILURE — TC-002: "This user already exist." pero API devuelve ""
  → Situación imposible con el diseño actual: TC-002 crea su propio usuario.
     Si ocurre, verificar conectividad con api.demoblaze.com.

BUILD FAILURE — TC-006: "Wrong password." esperado pero API retorna token
  → El testUser configurado tiene otro password. Usar:
     mvn test -DtestUser=mi_usuario -DtestPassword=mi_password_correcto
  → En login-invalid.json el password está fijo como WrongPassword_Invalid_999!
     asegurando que NUNCA coincida con el password real.

BUILD FAILURE — TC-005: "Auth_token:" esperado pero API retorna errorMessage
  → El usuario testUser no existe o su password es incorrecto.
     Crear el usuario o usar: mvn test -DtestUser=u -DtestPassword=p

BUILD FAILURE — Cannot find symbol / compile error
  → Verificar Java 17: java -version
  → Verificar JAVA_HOME apunta a Java 17.

BUILD FAILURE — dependency resolution error
  → Verificar conexión a Internet.
  → Ejecutar: mvn dependency:resolve -U

================================================================================
