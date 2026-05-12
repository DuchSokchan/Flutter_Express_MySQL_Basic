// user controller
import User from './user.model.js';
// const validateUser = require('./user.validate');
import userSchema from '../validation.js';


export const getUsers = async (req, res) => {
    try {
        const users = await User.getAll();
        res.json(users);
    } catch (err) {
        console.error('Error fetching users:', err);
        res.status(500).json({
            error: 'Internal server error'
        });
    }
};

export const addUser = async (req, res) => {

    try {
        const { error } = userSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: error.details[0].message
            });
        }
        const { name, position, salary } = req.body;
        if (name && position && salary) {
            const user = await User.create(name, position, salary);
            res.status(201).json({ id: user.insertId, name, position, salary });
        } else {
            res.status(400).json({ error: 'Name, position, and salary are required' });
        }
    } catch (err) {
        if (err.code === 'ER_LOCK_WAIT_TIMEOUT') {
            return res.status(500).json({
                error: 'Database is locked. Try again later.'
            });
        }
        console.error('Error adding user:', err);
        res.status(500).json({ error: 'User creation failed' });
    }
};
export const updateUser = async (req, res) => {
    try {
        // Extract parameters id and body data
        const { id } = req.params;
        // Extract name, position, salary from request body
        const { name, position, salary } = req.body;

        // Validation fields
        const { error } = userSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: error.details[0].message
            });
        }
        // Update user in database
        const result = await User.update(id, name, position, salary);
        // User not found
        if (result.affectedRows === 0) {
            return res.status(404).json({
                error: 'User not found'
            });
        }

        // Success response with updated user data
        res.status(200).json({
            message: 'User updated successfully',
            data: {
                id,
                name,
                position,
                salary
            }
        });
    } catch (err) {
        if (err.code === 'ER_LOCK_WAIT_TIMEOUT') {
            return res.status(500).json({
                error: 'Database is locked. Try again later.'
            });
        }
        console.error('Error updating user:', err);
        res.status(500).json({ error: 'User update failed' });
    }
};

export const deleteUser = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await User.delete(id);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ message: 'User deleted successfully' });
    } catch (err) {
        if (err.code === 'ER_LOCK_WAIT_TIMEOUT') {
            return res.status(500).json({
                error: 'Database is locked. Try again later.'
            });
        }
        console.error('Error deleting user:', err);
        res.status(500).json({ error: 'User deletion failed' });
    }
};