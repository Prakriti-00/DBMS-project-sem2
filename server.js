const express = require('express');
const mysql = require('mysql2/promise'); // Using promise-based version
const cors = require('cors');

const app = express();
const port = 3000;

// Middleware
app.use(express.json()); // Replaced body-parser with built-in express.json()
app.use(cors());

// Database connection pool (better than single connection)
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'Kriti@2006',
  database: 'project',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// POST /pets - Add a new pet
app.post('/pets', async (req, res) => {
  try {
    const { name, species, breed, age, user_id } = req.body;

    if (!user_id) {
      return res.status(400).json({ error: 'user_id is required' });
    }
    if (!name || !species) {
      return res.status(400).json({ error: 'name and species are required' });
    }

    const [result] = await pool.execute(
      'INSERT INTO pets (name, species, breed, age, user_id) VALUES (?, ?, ?, ?, ?)',
      [name, species, breed || 'Unknown', age || 0, user_id]
    );

    res.status(201).json({ 
      message: 'Pet added successfully',
      pet_id: result.insertId,
      name,
      species,
      breed: breed || 'Unknown',
      age: age || 0
    });

  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /pets - Get all pets (for frontend to sync)
app.get('/pets', async (req, res) => {
  try {
    const { user_id } = req.query;  // Assuming user_id comes from the query params

    if (!user_id) {
      return res.status(400).json({ error: 'user_id is required' });
    }

    const [rows] = await pool.execute('SELECT * FROM pets WHERE user_id = ?', [user_id]);
    res.json(rows);
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
// DELETE /pets/:id - Delete a pet by ID
// DELETE /pets/:id - Delete a pet by id
app.delete('/pets/:id', async (req, res) => {
    try {
        const petId = req.params.id;
        if (!petId) {
            return res.status(400).json({ error: 'Pet ID is required' });
        }

        const [result] = await pool.execute('DELETE FROM pets WHERE pet_id = ?', [petId]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Pet not found' });
        }

        res.json({ message: 'Pet deleted successfully' });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});
