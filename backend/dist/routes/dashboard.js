"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_1 = require("../middleware/auth");
const supabase_1 = require("../config/supabase");
const router = express_1.default.Router();
// GET /api/dashboard/stats
router.get('/stats', auth_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user.id;
        const userRole = req.user.role;
        if (userRole === 'student') {
            // 1. Student stats
            const { data: requests, error } = await supabase_1.supabaseAdmin
                .from('re_lab_requests')
                .select('id, status')
                .eq('student_id', userId);
            if (error) {
                return res.status(400).json({ error: error.message });
            }
            const total = requests?.length || 0;
            const pending = requests?.filter(r => ['TG_PENDING', 'LAB_TEACHER_PENDING', 'RELAB_TEACHER_PENDING', 'HOD_PENDING'].includes(r.status)).length || 0;
            const approved = requests?.filter(r => r.status === 'APPROVED').length || 0;
            const scheduled = requests?.filter(r => ['SLOT_SELECTED', 'SCHEDULED'].includes(r.status)).length || 0;
            const completed = requests?.filter(r => r.status === 'COMPLETED').length || 0;
            const rejected = requests?.filter(r => r.status === 'REJECTED').length || 0;
            return res.json({
                stats: {
                    total,
                    pending,
                    approved,
                    scheduled,
                    completed,
                    rejected,
                }
            });
        }
        else {
            // 2. Staff stats (TG, Lab Teacher, Re-Lab Teacher, HOD, Admin)
            let pendingMyStageCount = 0;
            if (userRole === 'teacher_guardian') {
                const { data: advisedStudents } = await supabase_1.supabaseAdmin
                    .from('students')
                    .select('id')
                    .eq('teacher_guardian_id', userId);
                const studentIds = advisedStudents?.map(s => s.id) || [];
                if (studentIds.length > 0) {
                    const { count } = await supabase_1.supabaseAdmin
                        .from('re_lab_requests')
                        .select('*', { count: 'exact', head: true })
                        .in('student_id', studentIds)
                        .eq('status', 'TG_PENDING');
                    pendingMyStageCount = count || 0;
                }
            }
            else if (userRole === 'lab_teacher') {
                const { count } = await supabase_1.supabaseAdmin
                    .from('re_lab_requests')
                    .select('*', { count: 'exact', head: true })
                    .eq('status', 'LAB_TEACHER_PENDING');
                pendingMyStageCount = count || 0;
            }
            else if (userRole === 'relab_teacher') {
                const { count } = await supabase_1.supabaseAdmin
                    .from('re_lab_requests')
                    .select('*', { count: 'exact', head: true })
                    .eq('status', 'RELAB_TEACHER_PENDING');
                pendingMyStageCount = count || 0;
            }
            else if (userRole === 'hod') {
                const { count } = await supabase_1.supabaseAdmin
                    .from('re_lab_requests')
                    .select('*', { count: 'exact', head: true })
                    .eq('status', 'HOD_PENDING');
                pendingMyStageCount = count || 0;
            }
            else if (userRole === 'admin') {
                const { count } = await supabase_1.supabaseAdmin
                    .from('re_lab_requests')
                    .select('*', { count: 'exact', head: true })
                    .in('status', ['TG_PENDING', 'LAB_TEACHER_PENDING', 'RELAB_TEACHER_PENDING', 'HOD_PENDING']);
                pendingMyStageCount = count || 0;
            }
            // Total pending across all queues
            const { count: totalPendingSystem } = await supabase_1.supabaseAdmin
                .from('re_lab_requests')
                .select('*', { count: 'exact', head: true })
                .in('status', ['TG_PENDING', 'LAB_TEACHER_PENDING', 'RELAB_TEACHER_PENDING', 'HOD_PENDING']);
            // Completed this calendar month
            const startOfMonth = new Date();
            startOfMonth.setDate(1);
            const startOfMonthStr = startOfMonth.toISOString().split('T')[0];
            const { count: completedMonth } = await supabase_1.supabaseAdmin
                .from('re_lab_slots')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'COMPLETED')
                .gte('date', startOfMonthStr);
            // Today's scheduled sessions
            const todayStr = new Date().toISOString().split('T')[0];
            const { data: todaySessions } = await supabase_1.supabaseAdmin
                .from('re_lab_slots')
                .select(`
          id, date, status,
          timetable:timetable_id (
            room, start_time, end_time,
            subject_lab (subject_name, subject_code)
          ),
          request:request_id (
            id,
            student:student_id (name, email)
          )
        `)
                .eq('date', todayStr);
            return res.json({
                stats: {
                    pendingMyStage: pendingMyStageCount,
                    totalPendingSystem: totalPendingSystem || 0,
                    completedThisMonth: completedMonth || 0,
                    todaySessionsCount: todaySessions?.length || 0,
                    todaySessions: todaySessions || [],
                }
            });
        }
    }
    catch (err) {
        console.error('Dashboard stats error:', err);
        res.status(500).json({ error: 'Internal server error fetching dashboard statistics' });
    }
});
exports.default = router;
