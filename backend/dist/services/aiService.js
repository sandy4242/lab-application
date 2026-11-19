"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseRoutineWithAI = exports.getAIResponse = exports.assembleContext = void 0;
const generative_ai_1 = require("@google/generative-ai");
const supabase_1 = require("../config/supabase");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const apiKey = process.env.GEMINI_API_KEY || '';
const genAI = apiKey ? new generative_ai_1.GoogleGenerativeAI(apiKey) : null;
// Dynamically assemble DB context for the user depending on their role
const assembleContext = async (userId, role) => {
    try {
        if (role === 'student') {
            // 1. Get profile details
            const { data: profile } = await supabase_1.supabaseAdmin
                .from('profiles')
                .select(`
          name, email,
          students (
            registration_number,
            sections (
              name, semester,
              departments (name)
            )
          )
        `)
                .eq('id', userId)
                .single();
            // 2. Get re-lab requests with their approvals and booked slots
            const { data: requests } = await supabase_1.supabaseAdmin
                .from('re_lab_requests')
                .select(`
          id, missed_date, reason, status, created_at,
          subject_lab (subject_name, subject_code),
          approvals (stage, status, remarks, approver_role, created_at),
          re_lab_slots (date, status, timetable:timetable_id (room, start_time, end_time))
        `)
                .eq('student_id', userId);
            const p = profile;
            const regNo = p?.students?.registration_number || 'N/A';
            const sem = p?.students?.sections?.semester || 'N/A';
            const sec = p?.students?.sections?.name || 'N/A';
            const dept = p?.students?.sections?.departments?.name || 'N/A';
            return `USER CONTEXT:
Role: Student
Name: ${profile?.name || 'Unknown'}
Email: ${profile?.email || 'N/A'}
Reg No: ${regNo}
Section: Sem ${sem} Sec ${sec} (${dept})

RE-LAB APPLICATIONS:
${requests && requests.length > 0 ? JSON.stringify(requests, null, 2) : 'No applications found.'}
`;
        }
        else {
            // It is a staff member (teacher/HOD/admin)
            const { data: profile } = await supabase_1.supabaseAdmin
                .from('profiles')
                .select(`
          name, role,
          teachers (
            departments (name, code)
          )
        `)
                .eq('id', userId)
                .single();
            // Get count of total pending applications in the system
            const { count: pendingTotal } = await supabase_1.supabaseAdmin
                .from('re_lab_requests')
                .select('*', { count: 'exact', head: true })
                .in('status', ['TG_PENDING', 'LAB_TEACHER_PENDING', 'RELAB_TEACHER_PENDING', 'HOD_PENDING']);
            // Get count of completed re-labs in the current month
            const startOfMonth = new Date();
            startOfMonth.setDate(1);
            const startOfMonthStr = startOfMonth.toISOString().split('T')[0];
            const { count: completedMonth } = await supabase_1.supabaseAdmin
                .from('re_lab_slots')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'COMPLETED')
                .gte('date', startOfMonthStr);
            // Get today's scheduled sessions
            const todayStr = new Date().toISOString().split('T')[0];
            const { data: todaySessions } = await supabase_1.supabaseAdmin
                .from('re_lab_slots')
                .select(`
          date, status,
          timetable:timetable_id (room, start_time, end_time, subject_lab (subject_name, subject_code)),
          request:request_id (student:student_id (name))
        `)
                .eq('date', todayStr);
            const p = profile;
            const deptName = p?.teachers?.departments?.name || 'N/A';
            return `USER CONTEXT:
Role: Staff (${profile?.role || 'Teacher'})
Name: ${profile?.name || 'Unknown'}
Department: ${deptName}

SYSTEM STATISTICS (FOR THE STAFF USER):
Total Re-Lab requests pending workflow actions globally: ${pendingTotal || 0}
Completed Re-Lab sessions this calendar month: ${completedMonth || 0}

RE-LAB SESSIONS SCHEDULED FOR TODAY (${todayStr}):
${todaySessions && todaySessions.length > 0 ? JSON.stringify(todaySessions, null, 2) : 'No sessions scheduled for today.'}
`;
        }
    }
    catch (error) {
        console.error('Error assembling AI context:', error);
        return 'Failed to assemble real-time database context due to a database query error.';
    }
};
exports.assembleContext = assembleContext;
const getAIResponse = async (userQuery, userId, role) => {
    if (!genAI) {
        return "The AI Assistant is currently unavailable because the GEMINI_API_KEY environment variable is not configured on the backend server.";
    }
    try {
        const context = await (0, exports.assembleContext)(userId, role);
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        const systemPrompt = `You are the Intelligent AI Assistant for the Digital Re-Lab Management System.
Your job is to assist students and teachers by answering questions, summarizing queues, explaining approval statuses/histories, and detailing timetable slot suggestions.

Here is the real-time database context for the logged-in user:
---
${context}
---

CRITICAL INSTRUCTIONS:
1. You are an informational assistant. You MUST NOT make any authoritative scheduling, approval, or booking decisions.
2. If a student asks to "book" or "approve" something, inform them politely that they must use the dedicated buttons on their dashboard to execute these actions.
3. Be professional, concise, and helpful. Always refer to details present in the USER CONTEXT if applicable.
4. If the user asks about something missing from their context, explain what is missing or ask them to check back after submitting their forms.
`;
        const chat = model.startChat({
            history: [
                {
                    role: 'user',
                    parts: [{ text: systemPrompt }],
                },
                {
                    role: 'model',
                    parts: [{ text: "Understood. I will act strictly as an informational assistant, explaining statuses, matching rules, and summaries, while deferring all authoritative booking and approval operations to the application's deterministic UI actions." }],
                },
            ],
        });
        const result = await chat.sendMessage(userQuery);
        const response = await result.response;
        return response.text();
    }
    catch (err) {
        console.error('Gemini API execution error:', err);
        return `AI Error: Failed to generate response from LLM API. Details: ${err.message || err}`;
    }
};
exports.getAIResponse = getAIResponse;
const parseRoutineWithAI = async (imageBase64, mimeType = 'image/jpeg', rawText) => {
    if (!genAI) {
        throw new Error('Gemini API is not configured on the server. Please set GEMINI_API_KEY.');
    }
    try {
        const model = genAI.getGenerativeModel({
            model: 'gemini-1.5-flash',
            generationConfig: {
                responseMimeType: 'application/json',
            },
        });
        const extractionPrompt = `You are an academic routine extraction engine. Given this class timetable or routine, extract all weekly class and lab periods.
Return ONLY a valid JSON array of objects with the exact schema:
[
  {
    "day_of_week": "Monday" | "Tuesday" | "Wednesday" | "Thursday" | "Friday" | "Saturday" | "Sunday",
    "slot_number": 1,
    "start_time": "09:00",
    "end_time": "10:00",
    "subject_code": "CS301",
    "subject_name": "Database Management Systems Lab",
    "room": "Lab 301",
    "teacher_name": "Prof. Rajesh Kumar",
    "is_lab": true
  }
]

Normalization Rules:
1. Normalize "day_of_week" to full English proper case ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday").
2. Normalize "start_time" and "end_time" to 24-hour "HH:MM" format (e.g., 09:00, 14:00, 16:30).
3. Set "is_lab" to true if the session indicates laboratory/practical/lab, otherwise false.
4. If "slot_number" is not explicitly given, sequence the periods sequentially starting from 1 for each day.
5. Provide reasonable defaults if teacher_name or room is not specified.`;
        const contents = [extractionPrompt];
        if (rawText && rawText.trim().length > 0) {
            contents.push(`\nROUTINE TEXT/DOCUMENT:\n${rawText}\n`);
        }
        if (imageBase64 && imageBase64.trim().length > 0) {
            // Clean base64 if it contains data prefix
            const cleanBase64 = imageBase64.replace(/^data:image\/[a-z]+;base64,/, '');
            contents.push({
                inlineData: {
                    data: cleanBase64,
                    mimeType: mimeType || 'image/jpeg',
                },
            });
        }
        const result = await model.generateContent(contents);
        const responseText = result.response.text();
        const parsed = JSON.parse(responseText);
        if (Array.isArray(parsed)) {
            return parsed;
        }
        else if (parsed && Array.isArray(parsed.slots)) {
            return parsed.slots;
        }
        else if (parsed && Array.isArray(parsed.routine)) {
            return parsed.routine;
        }
        else {
            return [];
        }
    }
    catch (error) {
        console.error('Error parsing routine with AI:', error);
        throw new Error(`Failed to extract routine: ${error.message || error}`);
    }
};
exports.parseRoutineWithAI = parseRoutineWithAI;
