package com.coresales.service.product.repository;

import com.coresales.service.product.model.Product;

import java.util.List;

public interface ProductRepositoryCustom {
    List<Product> listarProductos();
    Product buscarPorId(Long id);
    Product crearProducto(Product producto);
    Product actualizarProducto(Long id, Product producto);
    void eliminarProducto(Long id);
}
