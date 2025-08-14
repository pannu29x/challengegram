import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();
import { pool } from './db.js';
import authRoutes from './routes/auth.js';
import challengeRoutes from './routes/challenges.js';
import walletRoutes from './routes/wallet.js';
import adminRoutes from './routes/admin.js';
import socialRoutes from './routes/social.js';
import storyRoutes from './routes/stories.js';
import searchRoutes from './routes/search.js';

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use('/uploads', express.static('uploads'));

app.get('/api/health', (req, res) => res.json({ ok: true, time: new Date().toISOString() }));

app.use('/api/auth', authRoutes);
app.use('/api/challenges', challengeRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/social', socialRoutes);
app.use('/api/stories', storyRoutes);
app.use('/api/search', searchRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, async () => {
  console.log('ChallengeGram backend running on port', PORT);
  try {
    await pool.query('select 1');
    console.log('DB connected');
  } catch (e) {
    console.error('DB connection failed:', e.message);
  }
});
