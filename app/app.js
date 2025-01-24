const express = require('express');
const mysql = require('mysql2/promise'); // or require('mysql2') if you prefer callbacks
const app = express();

// Read MySQL connection details from environment variables
const {
  DB_HOST = 'localhost',
  DB_USER = 'root',
  DB_PASSWORD = '',
  DB_NAME = 'reversed_ip_db'
} = process.env;

// Create a connection pool (recommended for Node apps)
let pool;
(async function initializeDB() {
  try {
    pool = await mysql.createPool({
      host: DB_HOST,
      user: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME,
    });
    console.log('Connected to MySQL');
    
    // Create table if not exists
    await pool.query(`
      CREATE TABLE IF NOT EXISTS reversed_ips (
        id INT AUTO_INCREMENT PRIMARY KEY,
        reversed_ip VARCHAR(45) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    console.log('Ensured reversed_ips table exists');
  } catch (err) {
    console.error('Error initializing DB:', err);
  }
})();

// Helper function to reverse an IPv4 address by octets
function reverseIP(ip) {
  // ip might be "1.2.3.4" or "::ffff:1.2.3.4" for IPv4 mapped addresses
  // Let's extract the IPv4 portion by splitting on ':' and taking last part
  const parts = ip.split(':');
  const ipv4Part = parts[parts.length - 1]; // e.g., "1.2.3.4"
  
  const octets = ipv4Part.split('.');
  if (octets.length !== 4) {
    // Not a valid IPv4 - let's just return it as is or handle differently
    return ipv4Part;
  }
  return octets.reverse().join('.');
}

app.get('/', async (req, res) => {
  try {
    // `req.ip` can be in the form "::ffff:1.2.3.4" if behind IPv6 or node's default
    const originalIP = req.ip;
    const reversed = reverseIP(originalIP);

    // Insert the reversed IP into DB
    await pool.query(`INSERT INTO reversed_ips (reversed_ip) VALUES (?)`, [reversed]);

    res.send(`Your reversed IP is: ${reversed}`);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error processing your request.');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
