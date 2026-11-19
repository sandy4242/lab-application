"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireRoles = exports.requireAuth = void 0;
const supabase_1 = require("../config/supabase");
const requireAuth = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Unauthorized: Missing authorization header' });
        }
        const token = authHeader.split(' ')[1];
        // Validate the token with Supabase Auth
        const { data: { user }, error } = await supabase_1.supabaseAdmin.auth.getUser(token);
        if (error || !user) {
            return res.status(401).json({ error: 'Unauthorized: Invalid or expired session token' });
        }
        // Fetch the user's custom role and details from the profiles table
        const { data: profile, error: profileError } = await supabase_1.supabaseAdmin
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single();
        if (profileError || !profile) {
            return res.status(403).json({ error: 'Forbidden: Profile not configured' });
        }
        // Attach user details to the request object
        req.user = {
            id: profile.id,
            email: profile.email,
            name: profile.name,
            role: profile.role,
            phone: profile.phone,
        };
        req.token = token;
        next();
    }
    catch (error) {
        console.error('Authentication Middleware Error:', error);
        return res.status(500).json({ error: 'Internal Server Authentication Error' });
    }
};
exports.requireAuth = requireAuth;
const requireRoles = (allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ error: 'Unauthorized: Authentication credentials not found' });
        }
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({ error: `Forbidden: Role '${req.user.role}' is not authorized for this resource` });
        }
        next();
    };
};
exports.requireRoles = requireRoles;
