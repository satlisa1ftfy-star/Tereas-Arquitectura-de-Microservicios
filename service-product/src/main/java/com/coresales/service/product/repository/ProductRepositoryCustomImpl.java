package com.coresales.service.product.repository;

import com.coresales.service.product.model.Product;
import jakarta.persistence.EntityManager;
import jakarta.persistence.ParameterMode;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;

import java.util.List;

public class ProductRepositoryCustomImpl implements ProductRepositoryCustom {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public List<Product> listarProductos() {
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("usp_Producto_Listar", Product.class);
        query.execute();
        return query.getResultList();
    }

    @Override
    public Product buscarPorId(Long id) {
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("usp_Producto_ObtenerPorId", Product.class);
        query.registerStoredProcedureParameter("ProductoId", Long.class, ParameterMode.IN);
        query.setParameter("ProductoId", id);

        query.execute();
        List<Product> listProductos = query.getResultList();
        return listProductos.isEmpty() ? null : listProductos.get(0);
    }

    @Override
    public Product crearProducto(Product producto) {
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("usp_Producto_Insertar", Product.class);
        // Registramos todos los parámetros que necesita recibir el Stored Procedure
        query.registerStoredProcedureParameter("Codigo", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Nombre", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Descripcion", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("CategoriaProductoId", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("MarcaId", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("PrecioCompra", java.math.BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("PrecioVenta", java.math.BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("StockMinimo", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("StockInicial", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Activo", Boolean.class, ParameterMode.IN);

        // Seteamos los valores para cada parámetro
        query.setParameter("Codigo", producto.getCodigo());
        query.setParameter("Nombre", producto.getNombre());
        query.setParameter("Descripcion", producto.getDescripcion());
        query.setParameter("CategoriaProductoId", producto.getCategoriaProductoId());
        query.setParameter("MarcaId", producto.getMarcaId());
        query.setParameter("PrecioCompra", producto.getPrecioCompra());
        query.setParameter("PrecioVenta", producto.getPrecioVenta());
        query.setParameter("StockMinimo", producto.getStockMinimo());
        query.setParameter("StockInicial", producto.getStockInicial());
        query.setParameter("Activo", producto.getActivo());

        query.execute();
        List<Product> listProductos = query.getResultList();
        return listProductos.isEmpty() ? null : listProductos.get(0);
    }

    @Override
    public Product actualizarProducto(Long id, Product producto) {
        // Se limpia el contexto de persistencia para evitar que Hibernate devuelva
        // la entidad con id=id ya cacheada (con los valores antiguos) en lugar de
        // mapear la fila actualizada que retorna el stored procedure.
        entityManager.clear();
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("usp_Producto_Actualizar", Product.class);
        // Registramos todos los parámetros que necesita recibir el Stored Procedure
        query.registerStoredProcedureParameter("ProductoId", Long.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Codigo", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Nombre", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Descripcion", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("CategoriaProductoId", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("MarcaId", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("PrecioCompra", java.math.BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("PrecioVenta", java.math.BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("StockMinimo", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Activo", Boolean.class, ParameterMode.IN);

        // Seteamos los valores para cada parámetro
        query.setParameter("ProductoId", id);
        query.setParameter("Codigo", producto.getCodigo());
        query.setParameter("Nombre", producto.getNombre());
        query.setParameter("Descripcion", producto.getDescripcion());
        query.setParameter("CategoriaProductoId", producto.getCategoriaProductoId());
        query.setParameter("MarcaId", producto.getMarcaId());
        query.setParameter("PrecioCompra", producto.getPrecioCompra());
        query.setParameter("PrecioVenta", producto.getPrecioVenta());
        query.setParameter("StockMinimo", producto.getStockMinimo());
        query.setParameter("Activo", producto.getActivo());

        query.execute();
        List<Product> listProductos = query.getResultList();
        return listProductos.isEmpty() ? null : listProductos.get(0);
    }

    @Override
    public void eliminarProducto(Long id) {
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("usp_Producto_Eliminar");
        query.registerStoredProcedureParameter("ProductoId", Long.class, ParameterMode.IN);
        query.setParameter("ProductoId", id);
        query.execute();
    }
}
