package runners;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.DisplayName;

/**
 * ChallengeTest.java
 * ============================================================================
 * Runner principal del reto técnico Demoblaze.
 * Ejecuta TODOS los escenarios de signup.feature y login.feature.
 *
 * Escenarios cubiertos (10 en total):
 *   signup.feature → TC-001, TC-002, TC-003 (outline), TC-004 (outline)
 *   login.feature  → TC-005, TC-006, TC-007, TC-008 (outline), TC-009 (outline), TC-010 (outline)
 *
 * Ejecución:
 *   mvn test
 *   mvn test -Dtest=ChallengeTest
 *   mvn test -Dkarate.env=qa
 *   mvn test -DtestUser=mi_usuario -DtestPassword=mi_password
 *
 * Reporte generado en:
 *   target/surefire-reports/karate-reports/karate-summary.html
 * ============================================================================
 */
@DisplayName("Demoblaze API - Suite Completa")
class ChallengeTest {

    @Karate.Test
    @DisplayName("Ejecutar todos los escenarios: signup + login")
    Karate testAll() {
        return Karate.run("classpath:api/demoblaze")
                     .relativeTo(getClass());
    }

}
