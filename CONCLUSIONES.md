# Conclusiones de Pruebas API (Karate DSL)

## 1. Alcance de las pruebas
Se evaluaron los endpoints principales de autenticación y registro de la API de Demoblaze (`/login` y `/signup`), abarcando escenarios de éxito, validaciones de errores de usuario y contraseñas.

## 2. Funcionalidades evaluadas
- **Login:** Generación del token en login exitoso. Manejo de error de password incorrecto y de usuario inexistente.
- **Signup:** Registro exitoso generando usuarios dinámicamente para no colisionar. Manejo de error de usuario ya registrado.

## 3. Escenarios cubiertos
- **Login (Data-Driven con CSV):** Un Scenario Outline parametrizado dinámicamente mediante un CSV.
- **Login (Múltiples flujos):** Validación estructural de respuesta.
- **Signup:** Flujos independientes (sin dependencia cruzada de datos).

## 4. Escenarios no cubiertos
- Endpoints de catálogo (productos, categorías).
- Endpoints de carrito de compras y checkout.

## 5. Hallazgos y Comportamientos observados
- La API de Demoblaze es poco semántica con el estándar HTTP. Para todos los endpoints evaluados, incluso en errores de lógica de negocio (como password erróneo), **retorna HTTP Status 200 OK**. El verdadero resultado debe analizarse inspeccionando el `body` (`errorMessage` o la cadena del token).
- El token retornado en el `/login` no es un JWT estándar.
- La respuesta de `/signup` exitoso es simplemente un string vacío `""` con código 200.

## 6. Riesgos y Limitaciones
- **Falsos Positivos:** Al retornar HTTP 200 en errores, las pruebas tradicionales sin asserts fuertes en el payload pueden dar falsos positivos. Se mitiga validando schemas precisos en cada escenario.

## 7. Consideraciones Técnicas
- **Data-Driven Nivel API:** Se emplea `read(...)` nativo de Karate para inyectar variables en los *Scenario Outline* desde un `CSV`, reduciendo código duro en los `.feature`.
- **Estructura Reutilizable:** Se utilizaron schemas JSON (`target/surefire-reports/karate-reports`) en la carpeta compartida para aislar aserciones estructurales y evitar repetirlas por escenario.
- **Reportes:** Se integraron los reportes nativos de Karate visibles en el directorio de `surefire-reports` para mantener los estándares.

## 8. Recomendaciones
- Considerar reportar al equipo de backend la necesidad de estandarizar los códigos de error HTTP (400, 401, 403, 404, 409) para mejorar el consumo de la API por parte de los clientes frontend y facilitar el testing de automatización.
- Utilizar tokens JWT con tiempo de expiración y claims en lugar del string plano actual.

## 9. Opinión profesional
Karate DSL resultó extremadamente eficiente para modelar esta API. El uso de validaciones de JSON nativas de Karate nos permitió solventar fácilmente el antipatrón de diseño de la API (200 OK en errores) validando contra *schemas* específicos para éxito y fallo, garantizando la seguridad en la automatización.
