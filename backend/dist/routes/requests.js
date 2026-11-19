"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_1 = require("../middleware/auth");
const supabase_1 = require("../config/supabase");
const router = express_1.default.Router();
// 1. Create a new Re-Lab Request (Student only)
router.post('/', auth_1.requireAuth, (0, auth_1.requireRoles)(['student']), async (req, res) => {
    try {
        const studentId = req.user.id;
        const { subject_lab_id, missed_date, reason, submit = true, attachments = [] } = req.body;
        if (!subject_lab_id || !missed_date || !reason) {
            return res.status(400).json({ error: 'Subject/Lab, missed date, and reason are required' });
        }
        // Determine initial status
        const status = submit ? 'TG_PENDING' : 'DRAFT';
        // Create the request
        const { data: request, error: requestError } = await supabase_1.supabaseAdmin
            .from('re_lab_requests')
            .insert({
            student_id: studentId,
            subject_lab_id,
            missed_date,
            reason,
            status,
        })
            .select()
            .single();
        if (requestError || !request) {
            return res.status(400).json({ error: requestError?.message || 'Failed to create request' });
        }
        // Handle attachments if any
        const attachmentsToInsert = attachments.map((att) => ({
            request_id: request.id,
            file_path: att.file_path,
            file_name: att.file_name,
        }));
        if (attachmentsToInsert.length > 0) {
            const { error: attError } = await supabase_1.supabaseAdmin
                .from('attachments')
                .insert(attachmentsToInsert);
            if (attError) {
                console.error('Failed to save attachments:', attError);
            }
        }
        // Log the audit event
        await supabase_1.supabaseAdmin.from('audit_logs').insert({
            actor_id: studentId,
            action: submit ? 'REQUEST_SUBMITTED' : 'REQUEST_DRAFT_CREATED',
            entity_type: 're_lab_requests',
            entity_id: request.id,
            metadata: { missed_date, subject_lab_id },
        });
        // If submitted, notify the student's Teacher Guardian (TG)
        if (submit) {
            // Find Student's TG
            const { data: studentData } = await supabase_1.supabaseAdmin
                .from('students')
                .select('teacher_guardian_id')
                .eq('id', studentId)
                .single();
            if (studentData?.teacher_guardian_id) {
                await supabase_1.supabaseAdmin.from('notifications').insert({
                    user_id: studentData.teacher_guardian_id,
                    title: 'New Re-Lab Request Pending',
                    message: `Student ${req.user.name} has submitted a re-lab request for review.`,
                });
            }
        }
        res.status(211).json({
            message: submit ? 'Re-lab request submitted successfully' : 'Draft request saved',
            request,
        });
    }
    catch (err) {
        console.error('Create request error:', err);
        res.status(500).json({ error: 'Internal server error creating request' });
    }
});
// 2. Fetch list of requests (Filtered by user role)
router.get('/', auth_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user.id;
        const userRole = req.user.role;
        let query = supabase_1.supabaseAdmin
            .from('re_lab_requests')
            .select(`
        *,
        student:student_id (id, name, email),
        subject_lab:subject_lab_id (*, lab:lab_id (*)),
        attachments (*),
        approvals (*),
        re_lab_slots (*, timetable:timetable_id (*))
      `);
        if (userRole === 'student') {
            // Students see their own requests
            query = query.eq('student_id', userId);
        }
        else if (userRole === 'teacher_guardian') {
            // TGs see requests of students they advise, or where they are requested to approve
            const { data: advisedStudents } = await supabase_1.supabaseAdmin
                .from('students')
                .select('id')
                .eq('teacher_guardian_id', userId);
            const studentIds = advisedStudents?.map(s => s.id) || [];
            query = query.or(`student_id.in.(${studentIds.join(',')}),status.eq.TG_PENDING`);
        }
        else if (userRole === 'lab_teacher') {
            // Lab teachers see requests pending Lab Teacher approval, or matching their assigned subject labs
            const { data: teacherLabs } = await supabase_1.supabaseAdmin
                .from('subject_lab_teachers')
                .select('subject_lab_id')
                .eq('teacher_id', userId);
            const labIds = teacherLabs?.map(l => l.subject_lab_id) || [];
            query = query.or(`subject_lab_id.in.(${labIds.join(',')}),status.eq.LAB_TEACHER_PENDING`);
        }
        else if (userRole === 'relab_teacher') {
            // Re-lab teachers see requests assigned/scheduled for them or pending re-lab approval
            query = query.or('status.eq.RELAB_TEACHER_PENDING,status.eq.APPROVED,status.eq.SLOT_SELECTED,status.eq.SCHEDULED,status.eq.COMPLETED');
        }
        else if (userRole === 'hod') {
            // HODs see requests for their department
            const { data: hodDept } = await supabase_1.supabaseAdmin
                .from('teachers')
                .select('department_id')
                .eq('id', userId)
                .single();
            if (hodDept) {
                // Find subject labs in this department
                const { data: deptLabs } = await supabase_1.supabaseAdmin
                    .from('subject_labs')
                    .select('id')
                    .eq('department_id', hodDept.department_id);
                const labIds = deptLabs?.map(l => l.id) || [];
                query = query.in('subject_lab_id', labIds);
            }
        }
        const { data: requests, error } = await query.order('created_at', { ascending: false });
        if (error) {
            return res.status(400).json({ error: error.message });
        }
        res.json({ requests });
    }
    catch (err) {
        console.error('Fetch requests error:', err);
        res.status(500).json({ error: 'Internal server error fetching requests' });
    }
});
// 3. Fetch single request details
router.get('/:id', auth_1.requireAuth, async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const userRole = req.user.role;
        const { data: request, error } = await supabase_1.supabaseAdmin
            .from('re_lab_requests')
            .select(`
        *,
        student:student_id (
          id, name, email,
          students (
            registration_number,
            section:section_id (id, semester, name, departments (id, name, code)),
            teacher_guardian:teacher_guardian_id (id, name, email)
          )
        ),
        subject_lab:subject_lab_id (*, lab:lab_id (*)),
        attachments (*),
        approvals (*, approver:approver_id (id, name, role)),
        re_lab_slots (*, timetable:timetable_id (*, teacher:teacher_id (id, name)))
      `)
            .eq('id', id)
            .single();
        if (error || !request) {
            return res.status(404).json({ error: 'Request not found' });
        }
        // Security check: Ensure user is allowed to view
        if (userRole === 'student' && request.student_id !== userId) {
            return res.status(403).json({ error: 'Access denied' });
        }
        res.json({ request });
    }
    catch (err) {
        console.error('Fetch request details error:', err);
        res.status(500).json({ error: 'Internal server error fetching request details' });
    }
});
// 4. Submit an approval decision (TG, Lab Teacher, Re-Lab Teacher, HOD)
router.post('/:id/approve', auth_1.requireAuth, (0, auth_1.requireRoles)(['teacher_guardian', 'lab_teacher', 'relab_teacher', 'hod', 'admin']), async (req, res) => {
    try {
        const { id } = req.params;
        const { status, remarks, signature_info } = req.body;
        const approverId = req.user.id;
        const approverRole = req.user.role;
        if (!status || !['APPROVED', 'REJECTED'].includes(status)) {
            return res.status(400).json({ error: 'Status is required and must be either APPROVED or REJECTED' });
        }
        // 1. Fetch current request state
        const { data: request, error: reqError } = await supabase_1.supabaseAdmin
            .from('re_lab_requests')
            .select('*, student:student_id (id, name, students (teacher_guardian_id))')
            .eq('id', id)
            .single();
        if (reqError || !request) {
            return res.status(404).json({ error: 'Request not found or failed to fetch' });
        }
        // 2. Validate current workflow stage and role permission
        let expectedStatus = '';
        let stage = 0;
        let nextStatus = '';
        if (request.status === 'TG_PENDING') {
            expectedStatus = 'TG_PENDING';
            stage = 1;
            nextStatus = status === 'APPROVED' ? 'LAB_TEACHER_PENDING' : 'REJECTED';
            // Verify TG matches the student's TG
            if (approverRole === 'teacher_guardian' && request.student?.students?.teacher_guardian_id !== approverId) {
                return res.status(403).json({ error: 'Access denied. You are not the assigned Teacher Guardian for this student.' });
            }
        }
        else if (request.status === 'LAB_TEACHER_PENDING') {
            expectedStatus = 'LAB_TEACHER_PENDING';
            stage = 2;
            nextStatus = status === 'APPROVED' ? 'RELAB_TEACHER_PENDING' : 'REJECTED';
        }
        else if (request.status === 'RELAB_TEACHER_PENDING') {
            expectedStatus = 'RELAB_TEACHER_PENDING';
            stage = 3;
            nextStatus = status === 'APPROVED' ? 'HOD_PENDING' : 'REJECTED';
        }
        else if (request.status === 'HOD_PENDING') {
            expectedStatus = 'HOD_PENDING';
            stage = 4;
            nextStatus = status === 'APPROVED' ? 'APPROVED' : 'REJECTED';
        }
        else {
            return res.status(400).json({ error: `Request cannot be approved in its current state: ${request.status}` });
        }
        // Map stages to database approval role strings
        const stageRoles = ['teacher_guardian', 'lab_teacher', 'relab_teacher', 'hod'];
        const requiredRole = stageRoles[stage - 1];
        if (approverRole !== 'admin' && approverRole !== requiredRole) {
            return res.status(403).json({ error: `Only users with role '${requiredRole}' or 'admin' can approve this stage.` });
        }
        // 3. Write approval record
        const { error: approvalError } = await supabase_1.supabaseAdmin
            .from('approvals')
            .insert({
            request_id: id,
            approver_id: approverId,
            approver_role: approverRole === 'admin' ? requiredRole : approverRole,
            stage,
            status,
            remarks: remarks || '',
            signature_info: signature_info || '',
        });
        if (approvalError) {
            return res.status(400).json({ error: `Failed to record approval: ${approvalError.message}` });
        }
        // 4. Update request status
        const { error: updateError } = await supabase_1.supabaseAdmin
            .from('re_lab_requests')
            .update({ status: nextStatus })
            .eq('id', id);
        if (updateError) {
            return res.status(500).json({ error: `Failed to update request workflow: ${updateError.message}` });
        }
        // 5. Notify Student
        await supabase_1.supabaseAdmin.from('notifications').insert({
            user_id: request.student_id,
            title: 'Re-Lab Request Status Update',
            message: `Your re-lab request status was updated to ${nextStatus.replaceAll('_', ' ')} by ${req.user.name}.`,
        });
        // 6. Notify next role in queue if approved and not final
        if (status === 'APPROVED' && nextStatus !== 'APPROVED') {
            const nextRoleRequired = stageRoles[stage]; // next index
            const { data: staffList } = await supabase_1.supabaseAdmin
                .from('profiles')
                .select('id')
                .eq('role', nextRoleRequired);
            if (staffList && staffList.length > 0) {
                const notificationsToInsert = staffList.map(staff => ({
                    user_id: staff.id,
                    title: 'Pending Re-Lab Action Required',
                    message: `A re-lab request is now pending your stage (${nextRoleRequired.replaceAll('_', ' ')}).`,
                }));
                await supabase_1.supabaseAdmin.from('notifications').insert(notificationsToInsert);
            }
        }
        // 7. Audit log
        await supabase_1.supabaseAdmin.from('audit_logs').insert({
            actor_id: approverId,
            action: `STAGE_${stage}_${status}`,
            entity_type: 're_lab_requests',
            entity_id: id,
            metadata: { remarks, previous_status: request.status, next_status: nextStatus },
        });
        res.json({
            message: `Request successfully ${status.toLowerCase()}ed and advanced to ${nextStatus}`,
            nextStatus,
        });
    }
    catch (err) {
        console.error('Approve request error:', err);
        res.status(500).json({ error: 'Internal server error processing approval' });
    }
});
// Import matching and booking services
const matchingEngine_1 = require("../services/matchingEngine");
const bookingService_1 = require("../services/bookingService");
// 5. Get matching slots for approved request (Student only)
router.get('/:id/matches', auth_1.requireAuth, (0, auth_1.requireRoles)(['student']), async (req, res) => {
    try {
        const { id } = req.params;
        const matches = await (0, matchingEngine_1.findMatchingSlots)(id);
        res.json({ matches });
    }
    catch (err) {
        console.error('Matching slots route error:', err);
        res.status(500).json({ error: err.message || 'Internal server error resolving matching slots' });
    }
});
// 6. Book a matching slot (Student only)
router.post('/:id/book', auth_1.requireAuth, (0, auth_1.requireRoles)(['student']), async (req, res) => {
    try {
        const { id } = req.params;
        const { timetableId, date } = req.body;
        if (!timetableId || !date) {
            return res.status(400).json({ error: 'timetableId and date are required to book a slot' });
        }
        const result = await (0, bookingService_1.bookSlot)(id, timetableId, date);
        if (!result.success) {
            return res.status(400).json({ error: result.error || 'Failed to book slot' });
        }
        res.json({ message: 'Re-lab slot booked successfully' });
    }
    catch (err) {
        console.error('Book slot route error:', err);
        res.status(500).json({ error: 'Internal server error booking re-lab slot' });
    }
});
// 7. Mark re-lab session as completed (Re-Lab Teacher, HOD, Admin)
router.post('/:id/complete', auth_1.requireAuth, (0, auth_1.requireRoles)(['relab_teacher', 'hod', 'admin']), async (req, res) => {
    try {
        const { id } = req.params;
        const { remarks } = req.body;
        const teacherId = req.user.id;
        // Fetch request and verify status
        const { data: request, error: reqError } = await supabase_1.supabaseAdmin
            .from('re_lab_requests')
            .select('id, student_id, status')
            .eq('id', id)
            .single();
        if (reqError || !request) {
            return res.status(404).json({ error: 'Request not found' });
        }
        if (!['SLOT_SELECTED', 'SCHEDULED'].includes(request.status)) {
            return res.status(400).json({ error: `Cannot complete re-lab from state '${request.status}'. Slot must be selected/scheduled first.` });
        }
        // Update re_lab_slots status
        await supabase_1.supabaseAdmin
            .from('re_lab_slots')
            .update({ status: 'COMPLETED' })
            .eq('request_id', id);
        // Update re_lab_requests status
        await supabase_1.supabaseAdmin
            .from('re_lab_requests')
            .update({ status: 'COMPLETED' })
            .eq('id', id);
        // Record in audit_logs
        await supabase_1.supabaseAdmin.from('audit_logs').insert({
            actor_id: teacherId,
            action: 'RELAB_COMPLETED',
            entity_type: 're_lab_requests',
            entity_id: id,
            metadata: { remarks: remarks || 'Re-lab session completed successfully' },
        });
        // Notify the student
        await supabase_1.supabaseAdmin.from('notifications').insert({
            user_id: request.student_id,
            title: 'Re-Lab Session Completed',
            message: `Your re-lab session has been marked as COMPLETED by ${req.user.name}.`,
        });
        res.json({ message: 'Re-lab session marked as completed successfully', status: 'COMPLETED' });
    }
    catch (err) {
        console.error('Complete re-lab error:', err);
        res.status(500).json({ error: 'Internal server error completing re-lab session' });
    }
});
exports.default = router;
