import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import ip from 'ip';
import productRouter from './src/module/products/route.js';
import userRouter from './src/module/users/user.route.js';
import orderRouter from './src/module/orders/route.js';
const app = express();
const PORT = 3000;

app.use(cors());+
app.use(bodyParser.json());

// Use product routes
app.use('/api', productRouter);
app.use('/api', userRouter);
// app.use('/api', orderRouter);


app.listen(PORT, () => {
    console.log(`Server is running on http://${ip.address()}:${PORT}`);
});