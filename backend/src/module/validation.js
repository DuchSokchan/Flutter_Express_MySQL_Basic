// Validation 
import Joi from 'joi';
const productSchema = Joi.object({
    name: Joi.string().required(),
    description: Joi.string().required(),
    price: Joi.number().required()
});
const userSchema = Joi.object({
    name: Joi.string().required(),
    position: Joi.string().required(),
    salary: Joi.number().required()
});


export { productSchema, userSchema };