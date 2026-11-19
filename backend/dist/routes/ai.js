"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_1 = require("../middleware/auth");
const aiService_1 = require("../services/aiService");
const router = express_1.default.Router();
router.post('/chat', auth_1.requireAuth, async (req, res) => {
    try {
        const { message } = req.body;
        const userId = req.user.id;
        const userRole = req.user.role;
        if (!message || message.trim() === '') {
            return res.status(400).json({ error: 'Message query is required' });
        }
        const reply = await (0, aiService_1.getAIResponse)(message, userId, userRole);
        res.json({ response: reply });
    }
    catch (err) {
        console.error('AI chat endpoint error:', err);
        res.status(500).json({ error: 'Internal server error processing AI assistant query' });
    }
});
exports.default = router;
