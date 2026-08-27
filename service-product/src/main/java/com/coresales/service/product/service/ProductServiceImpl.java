package com.coresales.service.product.service;

import com.coresales.service.product.model.Product;
import com.coresales.service.product.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional
public class ProductServiceImpl implements ProductService{

    private final ProductRepository productoRepository;

    //==========================================
    // CONSTRUCTOR
    //==========================================
    public ProductServiceImpl(ProductRepository productoRepository) {
        this.productoRepository = productoRepository;
    }

    //==========================================
    // MÉTODOS
    //==========================================
    @Override
    @Transactional(readOnly = true)
    public List<Product> listar(){
        return new ArrayList<>(productoRepository.listarProductos());
    }

    @Override
    @Transactional(readOnly = true)
    public Product obtenerPorId(Long id) {
        return productoRepository.buscarPorId(id);
    }

    @Override
    public Product crear(Product producto){
        if (productoRepository.existsByCodigo(producto.getCodigo())) {
            throw new IllegalArgumentException(
                    "Ya existe un producto con el código indicado"
            );
        }

        if (producto.getActivo() == null) {
            producto.setActivo(true);
        }
        if (producto.getStockMinimo() == null) {
            producto.setStockMinimo(0);
        }
        if (producto.getStockInicial() == null) {
            producto.setStockInicial(0);
        }

        return productoRepository.crearProducto(producto);
    }

    @Override
    public Product actualizar(Long id, Product producto){
        Product productoBusqueda = obtenerPorId(id);

        if (productoBusqueda == null) return null;

        if (!producto.getCodigo().equals(productoBusqueda.getCodigo())
                && productoRepository.existsByCodigo(producto.getCodigo())
        ) {
            throw new IllegalArgumentException(
                    "El código ya pertenece a otro producto"
            );
        }

        return productoRepository.actualizarProducto(id, producto);
    }

    @Override
    public void eliminar(Long id){
        productoRepository.eliminarProducto(id);
        //Product producto = obtenerPorId(id);
        //productoRepository.delete(producto);
    }
}
