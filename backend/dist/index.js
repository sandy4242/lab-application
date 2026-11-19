"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 5000;
app.use((0, cors_1.default)({
    origin: 'http://localhost:3000',
    credentials: true
}));
app.use(express_1.default.json({ limit: '10mb' }));
// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// Import and register routes
const auth_1 = __importDefault(require("./routes/auth"));
const requests_1 = __importDefault(require("./routes/requests"));
const dashboard_1 = __importDefault(require("./routes/dashboard"));
const ai_1 = __importDefault(require("./routes/ai"));
const routine_1 = __importDefault(require("./routes/routine"));
app.use('/api/auth', auth_1.default);
app.use('/api/requests', requests_1.default);
app.use('/api/dashboard', dashboard_1.default);
app.use('/api/ai', ai_1.default);
app.use('/api/routine', routine_1.default);
// Global Error Handler
app.use((err, req, res, next) => {
    console.error('Unhandled Error:', err);
    res.status(500).json({ error: 'An unexpected internal error occurred.' });
});
app.listen(PORT, () => {
    console.log(`Backend server is running on http://localhost:${PORT}`);
});
