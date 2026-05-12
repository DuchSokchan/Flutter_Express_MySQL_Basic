// product model
import db from "../../../db.js";

const Product = {
    getAll: async () => {
        const [rows] = await db.query('SELECT * FROM products');
        return rows;
    },
    create: async (name, price, description) => {
        const [result] = await db.query('INSERT INTO products (name, price, description) VALUES (?, ?, ?)', [name, price, description]);
        return result;
    },
    update: async (id, name, price, description) => {
        const [result] = await db.query('UPDATE products SET name = ?, price = ?, description = ? WHERE id = ?', [name, price, description, id]);
        return result;
    },
    delete: async (id) => {
        const [result] = await db.query('DELETE FROM products WHERE id = ?', [id]);
        return result;
    }
};

export default Product;