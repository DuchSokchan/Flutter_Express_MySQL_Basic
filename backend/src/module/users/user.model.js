// User Model 
// const db = require('../../../db');
import db from "../../../db.js";


const User = {
    getAll: async () => {
        const [rows] = await db.query('SELECT * FROM users');
        return rows;
    },
    create: async (name, position, salary) => {
        const [result] = await db.query('INSERT INTO users (name, position, salary) VALUES (?, ?, ?)', [name, position, salary]);
        return result;
    },
    update: async (id, name, position, salary) => {
        const [result] = await db.query('UPDATE users SET name = ?, position = ?, salary = ? WHERE id = ?', [name, position, salary, id]);
        return result;
    },
    delete: async (id) => {
        const [result] = await db.query('DELETE FROM users WHERE id = ?', [id]);
        return result;
    }

};

export default User;