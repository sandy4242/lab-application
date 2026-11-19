import express from 'express';
import { requireAuth, AuthenticatedRequest } from '../middleware/auth';
import { getAIResponse } from '../services/aiService';

const router = express.Router();

router.post('/chat', requireAuth, async (req: AuthenticatedRequest, res) => {
  try {
    const { message } = req.body;
    const userId = req.user!.id;
    const userRole = req.user!.role;

    if (!message || message.trim() === '') {
      return res.status(400).json({ error: 'Message query is required' });
    }

    const reply = await getAIResponse(message, userId, userRole);
    res.json({ response: reply });
  } catch (err: any) {
    console.error('AI chat endpoint error:', err);
    res.status(500).json({ error: 'Internal server error processing AI assistant query' });
  }
});

export default router;
