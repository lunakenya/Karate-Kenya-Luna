Feature: Helper - Validar que el response contenga un token válido
  # Feature auxiliar llamado por karate.call() desde login.feature
  # Recibe: { resp: <response body> }

  @ignore
  Scenario: Verificar que response contiene prefijo Auth_token
    * match resp contains 'Auth_token:'
    * print '>>> Token válido confirmado.'
