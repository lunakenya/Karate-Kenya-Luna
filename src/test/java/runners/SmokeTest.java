package runners;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.DisplayName;

/**
 * SmokeTest.java
 * ============================================================================
 * Runner de validación rápida — ejecuta únicamente escenarios críticos.
 * Ideal para verificación post-deploy en pipelines CI/CD.
 *
 * Tags ejecutados: @smoke  (equivale a @critical)
 *
 * Escenarios incluidos:
 *   TC-001 → Crear usuario nuevo (signup exitoso)
 *   TC-005 → Login con credenciales válidas (token)
 *
 * Ejecución:
 *   mvn test -Dtest=SmokeTest
 *   mvn test -Dtest=SmokeTest -Dkarate.env=qa
 *   mvn test -Dtest=SmokeTest -DtestUser=mi_usuario -DtestPassword=mi_password
 *
 * Reporte generado en:
 *   target/surefire-reports/karate-reports/karate-summary.html
 * ============================================================================
 */
@DisplayName("Demoblaze API - Suite Smoke")
class SmokeTest {

    @Karate.Test
    @DisplayName("Ejecutar escenarios criticos (@smoke)")
    Karate testSmoke() {
        return Karate.run("classpath:api/demoblaze")
                     .tags("@smoke")
                     .relativeTo(getClass());
    }

}
