package com.coresales.service.product.model;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Producto")
@Data //agregar getters, setters y constructor sin parametro
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ProductoId")
    Long productoId;

    @Column(name = "Codigo", length = 30, nullable = false)
    String codigo;

    @Column(name = "Nombre", length = 150, nullable = false)
    String nombre;

    @Column(name="Descripcion",length = 500)
    String descripcion;

    @Column(name="CategoriaProductoId", nullable = false)
    Integer categoriaProductoId;

    @Column(name="MarcaId")
    Integer marcaId;

    @Column(name="PrecioCompra", precision = 12, scale = 2, nullable = false)
    BigDecimal precioCompra;

    @Column(name="PrecioVenta", precision = 12, scale = 2, nullable = false)
    BigDecimal precioVenta;

    @Column(name="StockMinimo")
    Integer stockMinimo;

    @Column(name="Activo")
    Boolean activo;

    @Column(name="FechaRegistro")
    LocalDateTime fechaRegistro;

    /**
     * Stock inicial de inventario al crear el producto (usado solo en el alta,
     * no existe como columna en Producto: alimenta @StockInicial de usp_Producto_Insertar).
     */
    @Transient
    Integer stockInicial;
}
