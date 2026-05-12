// Import the database connection
import productSchema from "../validation.js";
import Product from "./product.model.js";
// Get all products
export const getProducts = async (req, res) => {
    try {
        const products = await Product.getAll();
        res.json(products);
    } catch (err) {
        console.error('Error fetching products:', err);
        res.status(500).json({ error: 'Get products failed' });
    }
};

// Add a new product
export const addProduct = async (req, res) => {
    const { name, description, price } = req.body;

    // Joi validation
    const { error } = productSchema.validate(

        { name, description, price },
        { abortEarly: true }
    );

    if (error) {
        return res.status(400).json({
            error: error.details[0].message
        });
    }

    try {
        const result = await Product.create(name, price, description);
        return res.status(201).json({
            message: 'Product created successfully',
            data: {
                id: result.insertId,
                name,
                description,
                price
            }
        });

    } catch (err) {
        console.error('Error adding product:', err);
        return res.status(500).json({
            error: 'Add product failed'
        });
    }
};
// Update a product
export const updateProduct = async (req, res) => {
    const { id } = req.params;
    const { name, description, price } = req.body;
    try {
        const result = await Product.update(id, name, price, description);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }
        res.json({ id, name, description, price });
    } catch (err) {
        console.error('Error updating product:', err);
        res.status(500).json({ error: 'Update product failed' });
    }
};
// Delete a product
export const deleteProduct = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await Product.delete(id);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }
        res.sendStatus(204);
    } catch (err) {
        console.error('Error deleting product:', err);
        res.status(500).json({ error: 'Delete product failed' });
    }
};
