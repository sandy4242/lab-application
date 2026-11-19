# Re-Lab Portal — UI/UX Design System & Anti-“AI Look” Rules

This document outlines the strict design guidelines, color tokens, typography, and structural conventions for the Re-Lab mobile & web application.

---

## 1. Anti-“AI Look” Rules
1. **No Gradients (Except Login Header)**: Surfaces, buttons, cards, and backgrounds must be flat, high-contrast colors. The only permitted gradient is the mobile login hero container.
2. **No Glassmorphism**: Never use background blur (`BackdropFilter`), frosted semi-transparent panels, or glowing borders.
3. **No Emoji as Icons**: Use standard outlined Material symbols (`Icons.school_outlined`, `Icons.description_outlined`, `Icons.calendar_today_outlined`). Never use emojis (🎓, ⚡, 🚀, 🔬) as UI icons.
4. **No Cards Around Every Item**: Avoid wrapping every list item, row, or piece of metadata in an elevated card with margins.
5. **Prefer Compact List Rows with Hairline Dividers**: Use dense list rows separated by hairline dividers (`#E4E7E7`) over stacked floating cards (Linear / Google Classroom style).
6. **One Radius Standard**: Enforce a single border radius throughout the interface (`8px` or `6px`).
7. **One Shadow Level**: Use at most one subtle shadow level (`blurRadius: 3, offset: (0, 1), color: rgba(0,0,0,0.04)`) or flat hairline borders (`#E4E7E7`). Never use colored or multi-layered glow shadows.
8. **Single Accent Color**: Primary color is deep teal (`#0F766E`), used sparingly (primary buttons, active navigation, header, key accents only).
9. **Small Status Indicators**: Status is shown with a small `6px - 8px` dot or subtle text, not large colorful pills.
10. **One Clear Focal Element per Screen**: Each view must have one unambiguous action or focal widget.
11. **Left-Aligned Text**: Left-align headings, section titles, and body copy like a real production product. Avoid centered hero-style marketing headings inside app views.
12. **Complete State Coverage**: Always include clean loading, empty, and error states.

---

## 2. Color Tokens & Architecture
- **Primary Teal**: `#0F766E` (Deep Teal — used sparingly)
- **Background**: `#F7F8F8` (Neutral calm off-white)
- **Surface**: `#FFFFFF` (White containers & tables)
- **Hairline Border**: `#E4E7E7` (0.5px to 1px row and container borders)
- **Status Dots**:
  - Pending Review: `#D97706` (Amber dot)
  - Approved / Scheduled: `#0F766E` (Teal dot)
  - Rejected: `#DC2626` (Red dot)
  - Completed: `#16A34A` (Green dot)
- **Text Palette**:
  - Primary Title/Body: `#0F172A` (Slate-900)
  - Secondary Caption: `#475569` (Slate-600)
  - Muted Label: `#94A3B8` (Slate-400)

---

## 3. Product Inspirations & Archetypes
- **Google Classroom**: Overall tone, calm headers, dense assignments stream with hairline separators.
- **Linear**: Dense list rows, compact metadata lines, muted labels, 6px dot status indicators.
- **Google Calendar**: Structured 5-day / 6-period timetable grid with clear lab session blocks and conflict markers.
- **Swiggy Order Tracking**: Clean vertical approval stepper with continuous line, subtle check dots, timestamps, approver names, and plain-language remarks.

---

## 4. Realistic Indian College Academic Data
- **Real Subject Names**:
  - `Data Structures & Algorithms Lab (CS3101)`
  - `Computer Networks Lab (CS3102)`
  - `Database Management Systems Lab (CS3103)`
  - `Operating Systems Lab (CS3104)`
  - `Digital Electronics Lab (EC3101)`
- **Roll Numbers & Sections**:
  - `21BCE1001`, `21BCE1042`, `22BCSE088`, `20BIT015`
  - Sections: `CSE-5B`, `CSE-5A`, `ECE-3C`
- **Uneven Text Lengths**: Realistic experiment titles (e.g. *“Implementation of AVL Tree Rotations and Deletion Algorithms”* vs *“SQL Queries”*).
- **Teacher Remarks in Plain Language**:
  - *"Medical certificate from Apollo Clinic verified for viral fever on 12-Oct. Cleared."*
  - *"Syllabus alignment confirmed. Experiment 4 (Binary Search Trees) repetition approved."*
  - *"Lab capacity verified. Seat 18 assigned in Batch B2 on Thursday 2-4 PM."*
  - *"Cleared by HOD office. Quota verified."*
