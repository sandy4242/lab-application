import express from 'express';
import { requireAuth, AuthenticatedRequest } from '../middleware/auth';
import { supabaseAdmin } from '../config/supabase';

const router = express.Router();

// Get active profile details (with student/teacher fields resolved)
router.get('/profile', requireAuth, async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;

    if (userRole === 'student') {
      const { data: student, error } = await supabaseAdmin
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
    } else {
      // It's a teacher/HOD/admin
      const { data: teacher, error } = await supabaseAdmin
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
  } catch (err: any) {
    console.error('Fetch profile error:', err);
    res.status(500).json({ error: 'Internal server error fetching profile' });
  }
});

// Update profile details (phone, name, etc.)
router.put('/profile', requireAuth, async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user!.id;
    const { name, phone } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const { data: updatedProfile, error } = await supabaseAdmin
      .from('profiles')
      .update({ name, phone })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({ message: 'Profile updated successfully', profile: updatedProfile });
  } catch (err: any) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Internal server error updating profile' });
  }
});

export default router;
