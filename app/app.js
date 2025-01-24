const express = require('express');
const mysql = require('mysql2/promise'); // or 'mysql2' for callback-based
const app = express();

/** 
 * 1) Enable "trust proxy" so Express respects the X-Forwarded-For header.
 *    If you're behind multiple proxies, you could set the exact number
 *    (e.g., `app.set('trust proxy', 2)`) but `true` usually works if 
 *    you trust all upstream proxies.
 */
app.set('trust proxy', true);

// Read MySQL connection details from environment variables:
const {
  DB_HOST = 'localhost',
  DB_USER = 'root',
  DB_PASSWORD = '',
  DB_NAME = 'reversed_ip_db'
} = process.env;

// Create a connection pool (recommended for Node apps).
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
    
    // Create table if it doesn't exist
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
    // We won't crash the app here, but you might want to handle it differently
  }
})();

/**
 * Helper function to reverse an IPv4 address by octets.
 * If you may also have IPv6 addresses, you might need a more robust approach.
 */
function reverseIP(ip) {
  // ip might be "::ffff:1.2.3.4" if behind IPv6 or node uses IPv6 format.
  // Let's extract the IPv4 portion by splitting on ':' and taking the last part.
  const parts = ip.split(':');
  const ipv4Part = parts[parts.length - 1]; // e.g., "1.2.3.4"

  const octets = ipv4Part.split('.');
  if (octets.length !== 4) {
    // Not a valid IPv4 format—return as is, or handle differently if needed
    return ipv4Part;
  }
  // Reverse the octets, e.g. 1.2.3.4 -> 4.3.2.1
  return octets.reverse().join('.');
}

// Route to show and store the reversed IP
app.get('/', async (req, res) => {
  try {
    // 2) Once trust proxy is set, `req.ip` is the client’s real IP 
    //    from the X-Forwarded-For chain.
    const originalIP = req.ip;
    const reversed = reverseIP(originalIP);

    // Insert the reversed IP into DB
    await pool.query('INSERT INTO reversed_ips (reversed_ip) VALUES (?)', [reversed]);

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
