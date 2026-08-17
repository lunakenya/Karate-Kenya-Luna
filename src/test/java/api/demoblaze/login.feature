Feature: Login API - POST /login
  # ============================================================================
  # Endpoint : POST https://api.demoblaze.com/login
  # Propósito: Autenticación de usuarios en la plataforma Demoblaze.
  #
  # Comportamiento real de la API (verificado en ejecución):
  #   - Login exitoso           → HTTP 200 | body: "Auth_token: <token>" (string)
  #   - Password incorrecto     → HTTP 200 | body: {"errorMessage":"Wrong password."}
  #   - Usuario no existente    → HTTP 200 | body: {"errorMessage":"User does not exist."}
  #
  # NOTA: La API no usa códigos HTTP semánticos para errores funcionales.
  #       El token NO es un JWT estándar; es el username en Base64 + timestamp.
  # ============================================================================

  Background:
    * url baseUrl
    * def loginPath = '/login'

  # ============================================================================
  # TC-005 | @smoke @critical
  # Login con credenciales VÁLIDAS.
  # Valida: status 200, tipo string, prefijo "Auth_token:".
  # El usuario y password se leen de karate-config.js (testUser/testPassword).
  # ============================================================================
  @smoke @critical @login @positive
  Scenario: TC-005 - Login con credenciales validas retorna token de autenticacion
    * def payload = read('classpath:common/payloads/login-valid.json')

    Given path loginPath
    And   request payload
    When  method POST
    Then  status 200

    * def schema = read('classpath:common/schemas/login-success-response.json')
    And match response == schema
    And match response contains 'Auth_token:'

    * print '>>> [TC-005] Token recibido:', response

  # ============================================================================
  # TC-006 | @regression @negative
  # Login con usuario EXISTENTE pero PASSWORD INCORRECTO.
  # La API distingue este caso de un usuario inexistente.
  # Error esperado: "Wrong password."
  # ============================================================================
  @regression @negative @login
  Scenario: TC-006 - Login con password incorrecto retorna Wrong password
    * def payload = read('classpath:common/payloads/login-invalid.json')

    Given path loginPath
    And   request payload
    When  method POST
    Then  status 200

    * def schema = read('classpath:common/schemas/login-error-response.json')
    And match response == schema
    And match response.errorMessage == 'Wrong password.'

    * print '>>> [TC-006] Error esperado:', response.errorMessage

  # ============================================================================
  # TC-007 | @regression @negative
  # Login con usuario que NO EXISTE en el sistema.
  # La API diferencia este error del de password incorrecto.
  # Error esperado: "User does not exist."
  # ============================================================================
  @regression @negative @login
  Scenario: TC-007 - Login con usuario inexistente retorna User does not exist
    * def payload = { username: 'usuario_inexistente_xyz_99999', password: 'AnyPassword123!' }

    Given path loginPath
    And   request payload
    When  method POST
    Then  status 200

    * def schema = read('classpath:common/schemas/login-error-response.json')
    And match response == schema
    And match response.errorMessage == 'User does not exist.'

    * print '>>> [TC-007] Error esperado:', response.errorMessage

  # ============================================================================
  # Scenario Outline: Cobertura ampliada de login con tabla de datos.
  # Valida los tres comportamientos posibles del endpoint:
  #   1. Token (login exitoso)
  #   2. Wrong password (usuario existe, password erróneo)
  #   3. User does not exist (usuario desconocido)
  # ============================================================================
  @regression @login @outline
  Scenario Outline: TC-<row> - Login | <case>
    # Resolver username y password según flags de la tabla
    * def resolvedUser = '<useConfigUser>' == 'true' ? testUser : '<username>'
    * def resolvedPass = '<useConfigPass>' == 'true' ? testPassword : '<password>'
    * def payload      = { username: '#(resolvedUser)', password: '#(resolvedPass)' }

    Given path loginPath
    And   request payload
    When  method POST
    Then  status 200

    * def expectToken  = '<expectToken>' == 'true'
    * def tokenSchema  = read('classpath:common/schemas/login-success-response.json')
    * def errorSchema  = read('classpath:common/schemas/login-error-response.json')
    * def expectSchema = expectToken ? tokenSchema : errorSchema
    And match response == expectSchema

    * if (expectToken) karate.call('classpath:helpers/assert-token.feature', { resp: response })

    * print '>>> [TC-<row>] User:', resolvedUser, '| Response:', response

    Examples:
      | row | case                       | username                    | password                   | useConfigUser | useConfigPass | expectToken |
      | 008 | Login valido (config user) | -                           | -                          | true          | true          | true        |
      | 009 | Password incorrecto        | -                           | WrongPassword_Invalid_999! | true          | false         | false       |
      | 010 | Usuario inexistente        | usuario_outline_noexist_001 | AnyPassword!               | false         | false         | false       |


