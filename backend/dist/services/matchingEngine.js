"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.findMatchingSlots = void 0;
const supabase_1 = require("../config/supabase");
const findMatchingSlots = async (requestId) => {
    // 1. Fetch request details with student metadata
    const { data: request, error: reqError } = await supabase_1.supabaseAdmin
        .from('re_lab_requests')
        .select(`
      *,
      student:student_id (
        id, name,
        students (
          section_id,
          registration_number
        )
      )
    `)
        .eq('id', requestId)
        .single();
    if (reqError || !request) {
        throw new Error('Re-lab request not found');
    }
    const studentId = request.student_id;
    const sectionId = request.student?.students?.section_id;
    const subjectLabId = request.subject_lab_id;
    const missedDate = new Date(request.missed_date);
    const currentDate = new Date();
    // Start search window: max of missed date or current date
    const searchStart = new Date(Math.max(missedDate.getTime(), currentDate.getTime()));
    // Skip the current day if it's already late, start search from next day
    searchStart.setDate(searchStart.getDate() + 1);
    // 2. Fetch the student's regular timetable slots (student's busy slots)
    const { data: studentTimetable, error: tError } = await supabase_1.supabaseAdmin
        .from('timetables')
        .select('day_of_week, slot_number')
        .eq('section_id', sectionId);
    if (tError) {
        throw new Error(`Failed to load student timetable: ${tError.message}`);
    }
    // Check if student has personal uploaded routine slots in student_routines
    const { data: customRoutines } = await supabase_1.supabaseAdmin
        .from('student_routines')
        .select('day_of_week, slot_number')
        .eq('student_id', studentId);
    // Combine section timetable and custom routine slots into student busy slots
    const allBusySlots = [
        ...(studentTimetable?.map(t => `${t.day_of_week}_${t.slot_number}`) || []),
        ...(customRoutines?.map(r => `${r.day_of_week}_${r.slot_number}`) || [])
    ];
    // Create a quick lookup for student conflicts: 'Day_Slot'
    const studentBusySlots = new Set(allBusySlots);
    // 3. Find the student's original lab teacher and room for this subject
    const { data: originalSlot } = await supabase_1.supabaseAdmin
        .from('timetables')
        .select('teacher_id, room')
        .eq('section_id', sectionId)
        .eq('subject_lab_id', subjectLabId)
        .limit(1)
        .maybeSingle();
    const originalTeacherId = originalSlot?.teacher_id;
    const originalRoom = originalSlot?.room;
    // 4. Fetch all timetables for this subject_lab (potential slots)
    const { data: candidateTimetables, error: candError } = await supabase_1.supabaseAdmin
        .from('timetables')
        .select(`
      *,
      section:section_id (name),
      teacher:teacher_id (name),
      subject_lab:subject_lab_id (
        lab_id,
        lab:lab_id (capacity)
      )
    `)
        .eq('subject_lab_id', subjectLabId);
    if (candError || !candidateTimetables) {
        throw new Error(`Failed to load candidate timetables: ${candError?.message || 'No candidate timetables found'}`);
    }
    const candidates = [];
    const searchWindowDays = 14;
    // 5. Check each day in the 14-day search window
    for (let i = 0; i < searchWindowDays; i++) {
        const loopDate = new Date(searchStart);
        loopDate.setDate(loopDate.getDate() + i);
        // Format Date: YYYY-MM-DD
        const dateStr = loopDate.toISOString().split('T')[0];
        // Resolve day name
        const dayName = loopDate.toLocaleDateString('en-US', { weekday: 'long' });
        // Filter candidate timetable slots that match this day of the week
        const matchingDaySlots = candidateTimetables.filter(t => t.day_of_week === dayName);
        for (const slot of matchingDaySlots) {
            const slotKey = `${dayName}_${slot.slot_number}`;
            // --- HARD CONSTRAINT 1: Student timetable conflict ---
            if (studentBusySlots.has(slotKey)) {
                continue; // Exclude, student has regular class
            }
            // --- HARD CONSTRAINT 2: Duplicate re-lab booking for this student at this slot/date ---
            const { count: studentConfCount } = await supabase_1.supabaseAdmin
                .from('re_lab_slots')
                .select('*', { count: 'exact', head: true })
                .eq('date', dateStr)
                .eq('status', 'RESERVED') // Active booking
                .eq('timetable_id', slot.id)
                .eq('request_id', requestId);
            if (studentConfCount && studentConfCount > 0) {
                continue; // Student already booked this slot
            }
            // --- HARD CONSTRAINT 3: Lab Capacity ---
            // Get count of regular students in this slot's section
            const { count: regularStudentsCount, error: regCountError } = await supabase_1.supabaseAdmin
                .from('students')
                .select('*', { count: 'exact', head: true })
                .eq('section_id', slot.section_id);
            const nRegular = regularStudentsCount || 0;
            // Get count of booked re-lab students for this slot and date
            const { count: bookedReLabsCount } = await supabase_1.supabaseAdmin
                .from('re_lab_slots')
                .select('*', { count: 'exact', head: true })
                .eq('timetable_id', slot.id)
                .eq('date', dateStr)
                .in('status', ['RESERVED', 'ATTENDED', 'COMPLETED']);
            const nBooked = bookedReLabsCount || 0;
            const labCapacity = slot.subject_lab?.lab?.capacity || 30;
            if (nRegular + nBooked >= labCapacity) {
                continue; // Exclude, lab is full!
            }
            // --- SOFT CONSTRAINTS & MATCH SCORE CALCULATION ---
            let score = 0;
            // 1. Section Match (30%)
            const sectionMatch = slot.section_id === sectionId;
            if (sectionMatch)
                score += 30;
            // 2. Subject Match (25%)
            // Since we filtered candidateTimetables by subject_lab_id, this is always true
            score += 25;
            // 3. Teacher Match (20%)
            const teacherMatch = originalTeacherId && slot.teacher_id === originalTeacherId;
            if (teacherMatch)
                score += 20;
            // 4. Room Match (15%)
            const roomMatch = originalRoom && slot.room === originalRoom;
            if (roomMatch)
                score += 15;
            // 5. Proximity Preference (10%)
            // Closer date = higher score. i.e., index 0 = 10 pts, index 13 = 10 * (1 - 13/14) = 0.7 pts
            const proximityScore = 10 * (1 - (i / searchWindowDays));
            score += Math.round(proximityScore);
            candidates.push({
                timetable_id: slot.id,
                date: dateStr,
                day_of_week: dayName,
                slot_number: slot.slot_number,
                start_time: slot.start_time,
                end_time: slot.end_time,
                room: slot.room,
                teacher_name: slot.teacher?.name || 'Staff',
                section_name: slot.section?.name || 'Group',
                score: score,
                available_capacity: labCapacity - (nRegular + nBooked),
            });
        }
    }
    // Sort candidates by score descending
    return candidates.sort((a, b) => b.score - a.score);
};
exports.findMatchingSlots = findMatchingSlots;
