package com.coresales.service.product.service;

import com.coresales.service.product.model.Product;

import java.util.List;

public interface ProductService {
    List<Product> listar();
    Product obtenerPorId(Long id);
    Product crear(Product producto);
    Product actualizar(Long id, Product producto);
    void eliminar(Long id);
}
