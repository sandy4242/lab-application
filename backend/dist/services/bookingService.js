"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.bookSlot = void 0;
const supabase_1 = require("../config/supabase");
const bookSlot = async (requestId, timetableId, date) => {
    try {
        // Call the database function book_re_lab_slot
        const { data, error } = await supabase_1.supabaseAdmin.rpc('book_re_lab_slot', {
            p_request_id: requestId,
            p_timetable_id: timetableId,
            p_date: date,
        });
        if (error) {
            return { success: false, error: error.message };
        }
        if (data && data.success === false) {
            return { success: false, error: data.error };
        }
        return { success: true };
    }
    catch (err) {
        console.error('Booking service error:', err);
        return { success: false, error: err.message || 'Internal error in booking service' };
    }
};
exports.bookSlot = bookSlot;
