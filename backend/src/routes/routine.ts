import express from 'express';
import { requireAuth, requireRoles, AuthenticatedRequest } from '../middleware/auth';
import { supabaseAdmin } from '../config/supabase';
import { parseRoutineWithAI } from '../services/aiService';

const router = express.Router();

export interface RoutineSlotInput {
  day_of_week: string;
  slot_number: number;
  start_time: string;
  end_time: string;
  subject_code?: string;
  subject_name: string;
  room?: string;
  teacher_name?: string;
  is_lab?: boolean;
}

// 1. Get student routine (Student or Admin)
router.get('/', requireAuth, async (req: AuthenticatedRequest, res) => {
  try {
    const studentId = req.user!.id;

    // Check if the student has a custom uploaded routine
    const { data: customSlots, error } = await supabaseAdmin
      .from('student_routines')
      .select('*')
      .eq('student_id', studentId)
      .order('day_of_week', { ascending: true })
      .order('slot_number', { ascending: true });

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    if (customSlots && customSlots.length > 0) {
      return res.json({
        isCustom: true,
        slots: customSlots,
      });
    }

    // Fallback: Fetch regular section timetable for this student
    const { data: studentRecord } = await supabaseAdmin
      .from('students')
      .select('section_id')
      .eq('id', studentId)
      .single();

    if (studentRecord?.section_id) {
      const { data: sectionTimetable, error: ttError } = await supabaseAdmin
        .from('timetables')
        .select(`
          id, day_of_week, slot_number, start_time, end_time, room,
          teacher:teacher_id (name),
          subject_lab:subject_lab_id (subject_code, subject_name)
        `)
        .eq('section_id', studentRecord.section_id)
        .order('slot_number', { ascending: true });

      if (!ttError && sectionTimetable) {
        const mapped = sectionTimetable.map(item => ({
          id: item.id,
          day_of_week: item.day_of_week,
          slot_number: item.slot_number,
          start_time: item.start_time,
          end_time: item.end_time,
          subject_code: (item.subject_lab as any)?.subject_code || '',
          subject_name: (item.subject_lab as any)?.subject_name || 'Class',
          room: item.room,
          teacher_name: (item.teacher as any)?.name || 'Faculty',
          is_lab: (item.subject_lab as any)?.subject_name?.toLowerCase().includes('lab') || false,
        }));

        return res.json({
          isCustom: false,
          slots: mapped,
        });
      }
    }

    return res.json({
      isCustom: false,
      slots: [],
    });
  } catch (err: any) {
    console.error('Fetch routine error:', err);
    res.status(500).json({ error: 'Internal server error fetching routine' });
  }
});

// 2. Save / update student routine (bulk replace)
router.post('/', requireAuth, requireRoles(['student']), async (req: AuthenticatedRequest, res) => {
  try {
    const studentId = req.user!.id;
    const { slots } = req.body;

    if (!Array.isArray(slots) || slots.length === 0) {
      return res.status(400).json({ error: 'Slots array is required and cannot be empty' });
    }

    // Format slots for database insertion
    const recordsToInsert = slots.map((s: RoutineSlotInput) => ({
      student_id: studentId,
      day_of_week: s.day_of_week,
      slot_number: Number(s.slot_number),
      start_time: s.start_time,
      end_time: s.end_time,
      subject_code: s.subject_code || '',
      subject_name: s.subject_name || 'Subject',
      room: s.room || '',
      teacher_name: s.teacher_name || '',
      is_lab: Boolean(s.is_lab),
    }));

    // Delete existing custom routine slots
    await supabaseAdmin
      .from('student_routines')
      .delete()
      .eq('student_id', studentId);

    // Insert new custom routine slots
    const { data: inserted, error: insertError } = await supabaseAdmin
      .from('student_routines')
      .insert(recordsToInsert)
      .select();

    if (insertError) {
      return res.status(400).json({ error: insertError.message });
    }

    // Record audit log
    await supabaseAdmin.from('audit_logs').insert({
      actor_id: studentId,
      action: 'ROUTINE_UPLOADED',
      entity_type: 'student_routines',
      entity_id: studentId,
      metadata: { count: recordsToInsert.length },
    });

    res.json({
      message: 'Class routine updated successfully',
      count: inserted?.length || 0,
      slots: inserted,
    });
  } catch (err: any) {
    console.error('Save routine error:', err);
    res.status(500).json({ error: 'Internal server error saving routine' });
  }
});

// 3. AI-Powered Routine Extraction from Image / Document
router.post('/parse-ai', requireAuth, requireRoles(['student']), async (req: AuthenticatedRequest, res) => {
  try {
    const { imageBase64, mimeType, rawText } = req.body;

    if (!imageBase64 && !rawText) {
      return res.status(400).json({ error: 'Either imageBase64 or rawText is required for AI parsing' });
    }

    const extractedSlots = await parseRoutineWithAI(imageBase64, mimeType, rawText);

    res.json({
      message: 'Routine parsed successfully by AI',
      slots: extractedSlots,
    });
  } catch (err: any) {
    console.error('AI parse routine error:', err);
    res.status(500).json({ error: err.message || 'Failed to parse routine with AI' });
  }
});

// 4. Reset routine to departmental default
router.delete('/', requireAuth, requireRoles(['student']), async (req: AuthenticatedRequest, res) => {
  try {
    const studentId = req.user!.id;

    await supabaseAdmin
      .from('student_routines')
      .delete()
      .eq('student_id', studentId);

    res.json({ message: 'Custom routine cleared. Reverted to departmental section schedule.' });
  } catch (err: any) {
    console.error('Reset routine error:', err);
    res.status(500).json({ error: 'Internal server error resetting routine' });
  }
});

export default router;
