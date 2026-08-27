package com.coresales.service.product.repository;

import com.coresales.service.product.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long>, ProductRepositoryCustom {
    boolean existsByCodigo(String codigo);
}
