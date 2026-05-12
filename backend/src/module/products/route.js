// route products
import express from 'express';
const productRouter = express.Router();
import { getProducts, addProduct, updateProduct, deleteProduct } from './productController.js';

productRouter.get('/products', getProducts);
productRouter.post('/products', addProduct);
productRouter.put('/products/:id', updateProduct);
productRouter.delete('/products/:id', deleteProduct);

export default productRouter;