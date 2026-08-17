// =============================================================================
// karate-config.js
// Configuración global de Karate DSL — Reto Técnico Demoblaze.
// Se ejecuta automáticamente ANTES de cada Feature.
//
// Variables disponibles en todas las features:
//   baseUrl      → URL base de la API
//   testUser     → Usuario preexistente para casos de login/signup negativo
//   testPassword → Password del usuario preexistente
// =============================================================================

function fn() {

    // -------------------------------------------------------------------------
    // 1. Ambiente de ejecución (default: qa)
    //    Cambiar con:  mvn test -Dkarate.env=prod
    // -------------------------------------------------------------------------
    var env = karate.env || 'qa';
    karate.log('>>> Karate Env:', env);

    // -------------------------------------------------------------------------
    // 2. Configuración por ambiente
    // -------------------------------------------------------------------------
    var config = {
        env: env,
        baseUrl: 'https://api.demoblaze.com',

        // ---------------------------------------------------------------------
        // Credenciales del usuario PREEXISTENTE en Demoblaze.
        // Usado en: TC-002 (signup duplicado), TC-003 (login válido),
        //           TC-004 (login password incorrecto), Outlines.
        //
        // Para sobreescribir desde línea de comandos:
        //   mvn test -DtestUser=mi_usuario -DtestPassword=mi_password
        // ---------------------------------------------------------------------
        testUser    : karate.properties['testUser']     || 'test_existing_usr',
        testPassword: karate.properties['testPassword'] || 'Test@1234!'
    };

    // -------------------------------------------------------------------------
    // 3. Headers HTTP por defecto para todas las llamadas
    // -------------------------------------------------------------------------
    karate.configure('headers', {
        'Content-Type': 'application/json',
        'Accept'       : 'application/json'
    });

    // -------------------------------------------------------------------------
    // 4. Timeouts (ms)
    // -------------------------------------------------------------------------
    karate.configure('connectTimeout', 15000);
    karate.configure('readTimeout',    15000);

    // -------------------------------------------------------------------------
    // 5. SSL — deshabilitar validación de certificados en QA
    // -------------------------------------------------------------------------
    karate.configure('ssl', true);

    return config;
}
