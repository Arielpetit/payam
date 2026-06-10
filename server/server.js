const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// ─── In-memory store ────────────────────────────────────────────────────────
const transactions = {};   // transactionId → TransactionRecord
const users = {
  'usr_001': { id: 'usr_001', name: 'Ariel',             balance: 250000 },
  'usr_002': { id: 'usr_002', name: 'Jean-Baptiste',     balance: 50000  },
  'usr_003': { id: 'usr_003', name: 'Marie',             balance: 80000  },
  'usr_004': { id: 'usr_004', name: 'Papa',              balance: 30000  },
  'usr_005': { id: 'usr_005', name: 'Celestine',         balance: 120000 },
  'usr_006': { id: 'usr_006', name: 'Roland',            balance: 60000  },
};

// ─── Helpers ────────────────────────────────────────────────────────────────
function generateId() {
  return 'txn_' + Date.now() + '_' + Math.random().toString(36).slice(2, 7);
}

function log(msg, data) {
  const time = new Date().toISOString().slice(11, 19);
  console.log(`[${time}] ${msg}`, data ? JSON.stringify(data) : '');
}

// ─── Routes ─────────────────────────────────────────────────────────────────

// Health check
app.get('/ping', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

// List users (handy for testing)
app.get('/users', (req, res) => {
  res.json(Object.values(users).map(u => ({
    id: u.id, name: u.name, balance: u.balance
  })));
});

// POST /transaction/initiate
// Sender calls this to create a transaction before writing NFC
app.post('/transaction/initiate', (req, res) => {
  const { senderId, amount } = req.body;

  if (!senderId || !amount || amount <= 0) {
    return res.status(400).json({ success: false, error: 'Missing senderId or amount' });
  }

  const sender = users[senderId];
  if (!sender) {
    return res.status(404).json({ success: false, error: 'Sender not found' });
  }

  if (sender.balance < amount) {
    return res.status(400).json({ success: false, error: 'Insufficient balance' });
  }

  const transactionId = generateId();
  transactions[transactionId] = {
    transactionId,
    senderId,
    amount: parseFloat(amount),
    status: 'pending',
    createdAt: Date.now(),
    expiresAt: Date.now() + 30000, // 30 seconds
  };

  log('Transaction created', { transactionId, senderId, amount });
  res.json({ success: true, transactionId });
});

// POST /transaction/tap
// Receiver calls this after reading NFC tag — this is where money moves
app.post('/transaction/tap', (req, res) => {
  const { transactionId, receiverId } = req.body;

  if (!transactionId || !receiverId) {
    return res.status(400).json({ success: false, error: 'Missing transactionId or receiverId' });
  }

  const txn = transactions[transactionId];
  if (!txn) {
    return res.status(404).json({ success: false, error: 'Transaction not found' });
  }

  if (txn.status !== 'pending') {
    return res.status(400).json({ success: false, error: `Transaction already ${txn.status}` });
  }

  if (Date.now() > txn.expiresAt) {
    txn.status = 'expired';
    return res.status(400).json({ success: false, error: 'Transaction expired' });
  }

  if (txn.senderId === receiverId) {
    return res.status(400).json({ success: false, error: 'Cannot send to yourself' });
  }

  const sender = users[txn.senderId];
  const receiver = users[receiverId];

  if (!sender) return res.status(404).json({ success: false, error: 'Sender not found' });
  if (!receiver) {
    // Auto-register unknown receiver for testing
    users[receiverId] = { id: receiverId, name: receiverId, balance: 0 };
  }

  if (sender.balance < txn.amount) {
    txn.status = 'failed';
    return res.status(400).json({ success: false, error: 'Insufficient balance' });
  }

  // ── Execute transfer ──
  sender.balance   -= txn.amount;
  users[receiverId].balance += txn.amount;
  txn.status = 'completed';
  txn.receiverId = receiverId;
  txn.completedAt = Date.now();

  log('Transfer complete', {
    transactionId,
    from: sender.name,
    to: users[receiverId].name,
    amount: txn.amount,
    senderBalance: sender.balance,
    receiverBalance: users[receiverId].balance,
  });

  res.json({
    success: true,
    transactionId,
    amount: txn.amount,
    senderName: sender.name,
    receiverName: users[receiverId].name,
    senderNewBalance: sender.balance,
    receiverNewBalance: users[receiverId].balance,
  });
});

// GET /transaction/:id  — poll for status (sender uses this)
app.get('/transaction/:id', (req, res) => {
  const txn = transactions[req.params.id];
  if (!txn) return res.status(404).json({ success: false, error: 'Not found' });

  const sender = users[txn.senderId];
  const receiver = txn.receiverId ? users[txn.receiverId] : null;

  res.json({
    success: true,
    transactionId: txn.transactionId,
    status: txn.status,
    amount: txn.amount,
    senderName: sender?.name,
    receiverName: receiver?.name,
    senderNewBalance: sender?.balance,
    expired: Date.now() > txn.expiresAt && txn.status === 'pending',
  });
});

// GET /balance/:userId
app.get('/balance/:userId', (req, res) => {
  const user = users[req.params.userId];
  if (!user) return res.status(404).json({ success: false, error: 'User not found' });
  res.json({ success: true, userId: user.id, name: user.name, balance: user.balance });
});

// ─── Start ───────────────────────────────────────────────────────────────────
const PORT = 3000;
const os = require('os');

function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

app.listen(PORT, '0.0.0.0', () => {
  const localIP = getLocalIP();
  console.log('');
  console.log('  ✅ Payam backend running');
  console.log(`  📡 Local:   http://localhost:${PORT}`);
  console.log(`  📱 Phones:  http://${localIP}:${PORT}`);
  console.log('');
  console.log('  Endpoints:');
  console.log('    GET  /ping');
  console.log('    GET  /users');
  console.log('    POST /transaction/initiate');
  console.log('    POST /transaction/tap');
  console.log('    GET  /transaction/:id');
  console.log('    GET  /balance/:userId');
  console.log('');
});
