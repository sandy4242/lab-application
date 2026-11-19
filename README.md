# Digital Re-Lab Management System (with Timetable Matching & AI)

This is a complete, self-contained Flutter application implementing the college re-lab workflow, intelligent timetable matching, and an AI Chatbot Assistant.

---

## 🔑 Static Login Credentials (Zero-Config / Offline)

The app comes preloaded with static accounts for every role in the re-lab hierarchy. All accounts use the password: **`password123`**

| Role | Email | Password | Assigned Details / Features |
| :--- | :--- | :--- | :--- |
| **🎓 Student** | `student@relab.com` | `password123` | **Rahul Sharma** (21BCE1001, CSE-B). Apply for re-labs, book matched slots, view notifications, chat with AI assistant. |
| **🛡️ Teacher Guardian** | `tg@relab.com` | `password123` | **Dr. Ananya Sen (TG)**. Stage 1 approval queue for advised students. |
| **🧪 Lab Teacher** | `teacher@relab.com` | `password123` | **Prof. Rajesh Kumar (Lab Teacher)**. Stage 2 approval queue for practical courses. |
| **🔄 Re-Lab Teacher** | `relabteacher@relab.com` | `password123` | **Prof. Vikram Mehta (Re-Lab Teacher)**. Stage 3 approval queue & mark attendance/completion. |
| **🏛️ Head of Department (HOD)** | `hod@relab.com` | `password123` | **Dr. Ramesh Gupta (HOD)**. Stage 4 final departmental approvals. |
| **⚙️ Admin** | `admin@relab.com` | `password123` | **System Administrator**. Global queue oversight & system management. |

> 💡 **Quick Login Tip**: On the login screen, simply tap any of the role chips at the top to automatically fill the credentials and sign in with a single tap!

---

## 🚀 How to Run the Flutter App

1. Open your terminal in the `frontend/` directory:
   ```bash
   cd frontend
   ```
2. Run the application:
   - **On Android Phone**:
     ```bash
     flutter run
     ```
   - **On Chrome Web**:
     ```bash
     flutter run -d chrome
     ```
   - **Build Release APK**:
     ```bash
     flutter build apk --release
     ```
     *Output APK:* `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔄 Complete Workflow Walkthrough

1. **Log in as Student**:
   - Tap **"🎓 Student"** on the login screen (`student@relab.com`).
   - Click **"Apply for Re-Lab"**, choose **CS301 (DBMS Lab)**, select a missed date, enter a reason, attach a file, and submit.
   - Status updates to **`TG_PENDING`**.
2. **Stage 1 (Teacher Guardian Approval)**:
   - Log out and tap **"🛡️ Teacher Guardian"** (`tg@relab.com`).
   - In the pending queue, tap **"Approve"** on the student's request.
   - Status advances to **`LAB_TEACHER_PENDING`**.
3. **Stage 2 (Lab Teacher Approval)**:
   - Log in as **"🧪 Lab Teacher"** (`teacher@relab.com`) and click **"Approve"**.
   - Status advances to **`RELAB_TEACHER_PENDING`**.
4. **Stage 3 (Re-Lab Teacher Clearance)**:
   - Log in as **"🔄 Re-Lab Teacher"** (`relabteacher@relab.com`) and click **"Approve"**.
   - Status advances to **`HOD_PENDING`**.
5. **Stage 4 (HOD Final Approval)**:
   - Log in as **"🏛️ HOD"** (`hod@relab.com`) and click **"Approve"**.
   - Status transitions to **`APPROVED`**.
6. **Intelligent Timetable Matching & Slot Booking**:
   - Log back in as **"🎓 Student"** (`student@relab.com`).
   - The card will now show **`APPROVED`**. Click **"Select Slot"**.
   - The intelligent matching algorithm calculates weighted scores (Section Match: 30%, Subject: 25%, Teacher: 20%, Room: 15%, Proximity: 10%) and displays ranked candidate sessions (e.g. *96% Match, 89% Match*).
   - Tap **"Book This Slot"**. Status changes to **`SLOT_SELECTED`**.
7. **Mark Attendance & Completion**:
   - Log in as **"🔄 Re-Lab Teacher"** (`relabteacher@relab.com`).
   - Tap **"Mark Completed"** to record student attendance and complete the session.
8. **Interactive AI Assistant**:
   - Tap the bot icon in the bottom-right corner.
   - Ask: *"What is the status of my re-lab?"*, *"When is my scheduled slot?"*, *"What documents do I need?"*, or *"Summarize today's sessions"*.
9. **Student Class Routine Upload & Interactive Timetable**:
   - Tap **"My Routine & Timetable"** on the student dashboard or the calendar icon in the top bar.
   - Switch between **Daily Schedule View** (with Theory vs Practical lab badges, room, and faculty) and **Full Weekly Matrix Grid View**.
   - Tap **"Upload Routine"** to either:
     - Upload or paste a structured **CSV/JSON template** (with instant validation and downloadable template).
     - Scan a routine photo/PDF document using **Gemini AI** to automatically extract class slots.
   - The engine automatically synchronizes with the Re-Lab Matching Engine, excluding your busy class periods from available re-lab slots to eliminate schedule clashes!

