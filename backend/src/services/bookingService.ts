import { supabaseAdmin } from '../config/supabase';

export const bookSlot = async (
  requestId: string,
  timetableId: string,
  date: string
): Promise<{ success: boolean; error?: string }> => {
  try {
    // Call the database function book_re_lab_slot
    const { data, error } = await supabaseAdmin.rpc('book_re_lab_slot', {
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
  } catch (err: any) {
    console.error('Booking service error:', err);
    return { success: false, error: err.message || 'Internal error in booking service' };
  }
};
