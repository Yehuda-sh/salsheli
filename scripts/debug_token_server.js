// 🧪 Debug-only token server for emulator testing
// Generates Firebase custom tokens to bypass reCAPTCHA
// Usage: node scripts/debug_token_server.js
// Then in app, debug login calls: http://<server-ip>:9876/token?email=avi.cohen@demo.com

const http = require('http');
const admin = require('firebase-admin');
const sa = require('./firebase-service-account.json');

if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(sa) });
}
const db = admin.firestore();

const PORT = 9877;

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  const url = new URL(req.url, `http://localhost:${PORT}`);
  
  if (url.pathname === '/token') {
    const email = url.searchParams.get('email');
    if (!email) {
      res.writeHead(400);
      res.end(JSON.stringify({ error: 'email required' }));
      return;
    }
    
    try {
      // Find user by email
      const snap = await db.collection('users').where('email', '==', email).limit(1).get();
      if (snap.empty) {
        res.writeHead(404);
        res.end(JSON.stringify({ error: 'user not found' }));
        return;
      }
      
      const uid = snap.docs[0].id;
      const token = await admin.auth().createCustomToken(uid);
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ token, uid, email }));
    } catch (e) {
      res.writeHead(500);
      res.end(JSON.stringify({ error: e.message }));
    }
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🔑 Debug token server running on port ${PORT}`);
});
