Feature: Signup API - POST /signup
  # ============================================================================
  # Endpoint : POST https://api.demoblaze.com/signup
  # Propósito: Registro de nuevos usuarios en la plataforma Demoblaze.
  #
  # Comportamiento real de la API (verificado en ejecución):
  #   - Registro exitoso       → HTTP 200 | body: "" (string JSON vacío)
  #   - Usuario ya existente   → HTTP 200 | body: {"errorMessage":"This user already exist."}
  #
  # NOTA IMPORTANTE:
  #   La API no usa códigos HTTP semánticos para errores funcionales.
  #   Siempre retorna HTTP 200. El resultado se determina inspeccionando el body.
  #   → status 200 NO significa éxito funcional.
  # ============================================================================

  Background:
    * url baseUrl
    * def signupPath = '/signup'

  # ============================================================================
  # TC-001 | @smoke @critical @positive
  # Crear un nuevo usuario con username dinámico (timestamp).
  # Garantiza unicidad en cada ejecución sin depender de datos preexistentes.
  # Password reutiliza testPassword de karate-config.js para centralización.
  # ============================================================================
  @smoke @critical @signup @positive
  Scenario: TC-001 - Crear un nuevo usuario con username dinamico
    * def timestamp   = java.lang.System.currentTimeMillis()
    * def newUsername = 'user_' + timestamp
    * def payload     = { username: '#(newUsername)', password: '#(testPassword)' }

    Given path signupPath
    And   request payload
    When  method POST
    Then  status 200

    # Validar que la API retornó string vacío (comportamiento real de Demoblaze)
    * def schema = read('classpath:common/schemas/signup-success-response.json')
    And match response == schema

    * print '>>> [TC-001] PASS - Usuario creado:', newUsername

  # ============================================================================
  # TC-002 | @regression @negative
  # Intentar registrar un usuario que YA EXISTE.
  #
  # DISEÑO DE DATO AUTÓNOMO:
  #   Este escenario NO depende de ningún usuario preexistente en el servidor.
  #   Crea su propio usuario dinámico en el paso 1, luego intenta registrarlo
  #   nuevamente en el paso 2. Esto garantiza reproducibilidad total del reto.
  #
  # Flujo:
  #   1. Registrar usuario nuevo dinámico → esperar "" (éxito)
  #   2. Intentar registrar el MISMO usuario → esperar errorMessage
  # ============================================================================
  @regression @negative @signup
  Scenario: TC-002 - Registro de usuario duplicado retorna errorMessage
    # --- Paso 1: Crear el usuario dinámico que luego se intentará duplicar ---
    * def timestamp   = java.lang.System.currentTimeMillis()
    * def dupUsername = 'dup_' + timestamp
    * def payloadNew  = { username: '#(dupUsername)', password: '#(testPassword)' }

    Given path signupPath
    And   request payloadNew
    When  method POST
    Then  status 200
    And   match response == read('classpath:common/schemas/signup-success-response.json')

    * print '>>> [TC-002] Setup: usuario creado para prueba de duplicado:', dupUsername

    # --- Paso 2: Intentar registrar el mismo usuario nuevamente ---
    * def payloadDup = { username: '#(dupUsername)', password: '#(testPassword)' }

    Given path signupPath
    And   request payloadDup
    When  method POST
    Then  status 200

    # Validar schema y mensaje exacto de error
    * def schema = read('classpath:common/schemas/signup-error-response.json')
    And match response == schema
    And match response.errorMessage == 'This user already exist.'

    * print '>>> [TC-002] PASS - Error esperado recibido:', response.errorMessage


  # ============================================================================
  # Scenario Outline: Cobertura ampliada con tabla de datos.
  # Demuestra el patrón de parametrización en Karate para múltiples variantes.
  #   - TC-003: Usuario nuevo dinámico → éxito ("")
  #   - TC-004: Usuario del config preexistente → error (ya existe)
  #
  # Tags aplicados a nivel de Outline. La fila 004 es @negative implícitamente
  # porque expectedStatus = error (validado en el cuerpo del escenario).
  # ============================================================================
  @regression @signup @outline
  Scenario Outline: TC-<row> - Signup | <case>
    * def ts           = java.lang.System.currentTimeMillis()
    * def resolvedUser = '<isDynamic>' == 'true' ? 'dyn_' + ts : testUser
    * def payload      = { username: '#(resolvedUser)', password: '<password>' }

    Given path signupPath
    And   request payload
    When  method POST
    Then  status 200

    * def expectSuccess  = '<expectedStatus>' == 'success'
    * def successSchema  = read('classpath:common/schemas/signup-success-response.json')
    * def errorSchema    = read('classpath:common/schemas/signup-error-response.json')
    * def expectedSchema = expectSuccess ? successSchema : errorSchema
    And match response == expectedSchema

    * print '>>> [TC-<row>] User:', resolvedUser, '| Response:', response

    Examples:
      | row | case                          | password     | isDynamic | expectedStatus |
      | 003 | Nuevo usuario dinamico        | SecureP@ss1! | true      | success        |
      | 004 | Usuario preexistente (config) | Test@1234!   | false     | error          |
