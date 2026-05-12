// route users
import express from 'express';
const router = express.Router();
import { getUsers, addUser, updateUser, deleteUser } from './user.controller.js';
// Get all users
router.get('/users', getUsers);
router.post('/users', addUser);
router.put('/users/:id', updateUser);
router.delete('/users/:id', deleteUser);

export default router;