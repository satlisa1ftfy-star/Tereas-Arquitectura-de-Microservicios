# Tarea: Servicio de Productos (CoreSales)

Microservicio Spring Boot (`service-product`) del sistema CoreSales, responsable del CRUD de
productos sobre SQL Server, incluyendo la creación automática del registro de inventario asociado.

## Arquitectura

- **Spring Boot 4 / Java 17** con Spring Data JPA + `mssql-jdbc`.
- El acceso a datos usa **stored procedures** (`usp_Producto_*`) definidos en
  [`database/CoreSales_Database.sql`](database/CoreSales_Database.sql), invocados vía
  `EntityManager.createStoredProcedureQuery(...)` en `ProductRepositoryCustomImpl`.
- Capas: `controller` → `service` → `repository` (interfaz + implementación custom sobre SPs).

## Endpoints (`/api/productos`)

| Método | Ruta                | Descripción                                              |
|--------|---------------------|-----------------------------------------------------------|
| GET    | `/api/productos`     | Lista todos los productos (con categoría, marca y stock)  |
| GET    | `/api/productos/{id}`| Obtiene un producto por id (404 si no existe)              |
| POST   | `/api/productos`     | Crea un producto (y su inventario inicial). 409 si el código ya existe |
| PUT    | `/api/productos/{id}`| Actualiza un producto (404 si no existe, 409 si el código choca con otro) |
| DELETE | `/api/productos/{id}`| Baja lógica (`Activo=0`), 204 sin contenido                |

Colección de Postman lista para importar: [`postman/service-product.postman_collection.json`](postman/service-product.postman_collection.json).

## Configuración de base de datos

`src/main/resources/application.properties` apunta a SQL Server con autenticación SQL (`sa`):

```properties
spring.datasource.url=jdbc:sqlserver://DESKTOP-74J9C9N:1433;databaseName=CoreSales;encrypt=true;trustServerCertificate=true
spring.datasource.username=sa
spring.datasource.password=${DB_PASSWORD}
```

La contraseña **no** está hardcodeada en el repositorio (es público). Antes de ejecutar el
proyecto, define la variable de entorno `DB_PASSWORD` con la contraseña real del login `sa`:

```powershell
$env:DB_PASSWORD = "tu-password-sa"
.\mvnw.cmd spring-boot:run
```

```bash
DB_PASSWORD=tu-password-sa ./mvnw spring-boot:run
```

Si tu SQL Server corre en otro host/instancia, ajusta también `spring.datasource.url`.

## Base de datos

El script completo del esquema (tablas, datos semilla y stored procedures de `Cliente`,
`Producto`, `Inventario`, `Venta`, etc.) está en [`database/CoreSales_Database.sql`](database/CoreSales_Database.sql).
Ejecútalo una vez contra tu instancia de SQL Server antes de levantar el servicio.

## Bug corregido durante las pruebas

Al actualizar un producto, Hibernate devolvía los valores **anteriores** en la respuesta: la
entidad ya quedaba cacheada en el contexto de persistencia (se cargaba antes para validar
existencia/código duplicado) y esa instancia cacheada se reutilizaba en vez de mapear la fila
recién actualizada que retorna el stored procedure. Se corrigió llamando
`entityManager.clear()` justo antes de ejecutar `usp_Producto_Actualizar`
(ver `ProductRepositoryCustomImpl.actualizarProducto`).
