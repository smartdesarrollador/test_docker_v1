<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $products = [
            [
                'nombre' => 'Laptop HP Pavilion',
                'descripcion' => 'Laptop de alto rendimiento con procesador Intel Core i7, 16GB RAM, 512GB SSD',
                'precio' => 899.99,
                'stock' => 15,
                'imagen' => 'laptop-hp.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Mouse Logitech MX Master 3',
                'descripcion' => 'Mouse inalámbrico ergonómico con precisión avanzada',
                'precio' => 99.99,
                'stock' => 50,
                'imagen' => 'mouse-logitech.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Teclado Mecánico RGB',
                'descripcion' => 'Teclado mecánico con iluminación RGB personalizable y switches Cherry MX',
                'precio' => 149.99,
                'stock' => 30,
                'imagen' => 'teclado-rgb.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Monitor LG 27" 4K',
                'descripcion' => 'Monitor 4K UHD de 27 pulgadas con tecnología IPS y HDR10',
                'precio' => 449.99,
                'stock' => 20,
                'imagen' => 'monitor-lg.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Webcam Full HD',
                'descripcion' => 'Cámara web 1080p con enfoque automático y micrófono integrado',
                'precio' => 79.99,
                'stock' => 40,
                'imagen' => 'webcam-hd.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Auriculares Sony WH-1000XM5',
                'descripcion' => 'Auriculares inalámbricos con cancelación de ruido activa',
                'precio' => 349.99,
                'stock' => 25,
                'imagen' => 'auriculares-sony.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'SSD Samsung 1TB',
                'descripcion' => 'Disco SSD NVMe de 1TB con velocidades de lectura de hasta 3500 MB/s',
                'precio' => 129.99,
                'stock' => 60,
                'imagen' => 'ssd-samsung.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Router WiFi 6',
                'descripcion' => 'Router inalámbrico con tecnología WiFi 6 y cobertura de hasta 200m²',
                'precio' => 199.99,
                'stock' => 35,
                'imagen' => 'router-wifi6.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Tablet Samsung Galaxy Tab',
                'descripcion' => 'Tablet Android de 10.5" con S-Pen incluido',
                'precio' => 429.99,
                'stock' => 18,
                'imagen' => 'tablet-samsung.jpg',
                'activo' => true
            ],
            [
                'nombre' => 'Impresora HP LaserJet',
                'descripcion' => 'Impresora láser monocromática con WiFi y velocidad de 30 ppm',
                'precio' => 249.99,
                'stock' => 12,
                'imagen' => 'impresora-hp.jpg',
                'activo' => true
            ]
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}
