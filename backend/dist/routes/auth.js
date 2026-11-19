"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_1 = require("../middleware/auth");
const supabase_1 = require("../config/supabase");
const router = express_1.default.Router();
// Get active profile details (with student/teacher fields resolved)
router.get('/profile', auth_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user.id;
        const userRole = req.user.role;
        if (userRole === 'student') {
            const { data: student, error } = await supabase_1.supabaseAdmin
                .from('profiles')
                .select(`
          id, email, name, phone, role,
          students (
            registration_number,
            section_id,
            sections (
              id, semester, name,
              departments (id, name, code)
            ),
            teacher_guardian:teacher_guardian_id (
              id, name, email
            )
          )
        `)
                .eq('id', userId)
                .single();
            if (error || !student) {
                return res.status(404).json({ error: 'Student profile details not found' });
            }
            return res.json({ profile: student });
        }
        else {
            // It's a teacher/HOD/admin
            const { data: teacher, error } = await supabase_1.supabaseAdmin
                .from('profiles')
                .select(`
          id, email, name, phone, role,
          teachers (
            department_id,
            departments (id, name, code)
          )
        `)
                .eq('id', userId)
                .single();
            if (error || !teacher) {
                return res.status(404).json({ error: 'Staff profile details not found' });
            }
            return res.json({ profile: teacher });
        }
    }
    catch (err) {
        console.error('Fetch profile error:', err);
        res.status(500).json({ error: 'Internal server error fetching profile' });
    }
});
// Update profile details (phone, name, etc.)
router.put('/profile', auth_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, phone } = req.body;
        if (!name) {
            return res.status(400).json({ error: 'Name is required' });
        }
        const { data: updatedProfile, error } = await supabase_1.supabaseAdmin
            .from('profiles')
            .update({ name, phone })
            .eq('id', userId)
            .select()
            .single();
        if (error) {
            return res.status(400).json({ error: error.message });
        }
        res.json({ message: 'Profile updated successfully', profile: updatedProfile });
    }
    catch (err) {
        console.error('Update profile error:', err);
        res.status(500).json({ error: 'Internal server error updating profile' });
    }
});
exports.default = router;
