---
name: anti-ai-ui-rules
description: Strict guidelines for building calm, dense, functional, and realistic enterprise/academic mobile & web interfaces without AI-generated design tropes.
---

# Anti-“AI Look” Design Guidelines & Standards

These rules prevent synthetic, template-like "AI generated" aesthetics and enforce calm, production-grade, functional software design inspired by **Linear**, **Google Classroom**, **Google Calendar**, and **Swiggy**.

---

## 1. Core Visual Principles
- **No Gradients (Except Login Header)**: Surfaces, buttons, cards, and backgrounds must be solid, high-contrast colors. The only permitted gradient is the top brand hero container on the Login screen.
- **No Glassmorphism**: Never use background blur (`BackdropFilter`), frosted semi-transparent panels, or glowing borders.
- **No Emojis as Icons**: Use standard outlined Material symbols (`Icons.school_outlined`, `Icons.description_outlined`, `Icons.calendar_today_outlined`). Never use emojis (🎓, ⚡, 🚀, 🔬) as UI icons.
- **No Cards Around Every Item**: Avoid wrapping every list item, row, or piece of metadata in an elevated card with margins.
- **Dense List Rows with Hairline Dividers**: Prefer compact list rows separated by `0.5px - 1px` hairline dividers (`#E4E7E7`) over stacked floating cards (Linear / Google Classroom model).
- **Single Radius Standard**: Enforce exactly one border radius throughout the interface (`8px` or `6px`). Do not mix `4px`, `12px`, `24px`, and `36px` arbitrarily.
- **Single Shadow Level**: Use at most one subtle shadow level (`blurRadius: 3, offset: (0, 1), color: rgba(0,0,0,0.04)`) or flat borders with `#E4E7E7`. Never use colored, glowing, or multi-layered drop shadows.

---

## 2. Color Palette & Restraint
- **Primary Accent (`#0F766E`)**: Deep academic teal. Use sparingly for:
  - Primary call-to-action buttons
  - Active navigation indicators
  - Mobile login/portal header
  - Focused interactive states
- **Neutral Background (`#F7F8F8`)**: Calm, off-white background across all screens.
- **Surface (`#FFFFFF`)**: Pure white content containers and dense list tables.
- **Hairline Borders (`#E4E7E7`)**: 1px subtle divider lines between rows and headers.
- **Status Indicators**:
  - Never use large, brightly colored pills or badges.
  - Show status with a small `6px - 8px` dot and muted caption text:
    - Pending: `#D97706` (Amber dot)
    - Approved / Scheduled: `#0F766E` (Teal dot)
    - Rejected: `#DC2626` (Red dot)
    - Completed: `#16A34A` (Green dot)
- **Light Mode First**: Clean, high-legibility daytime academic software.

---

## 3. Layout, Hierarchy & Focal Element
- **One Clear Focal Element per Screen**:
  - Student Dashboard: Active request status / "New Request" action.
  - Request Detail: Approval timeline & action button.
  - Timetable Screen: Weekly routine calendar grid.
- **Left-Aligned Text**: Left-align headings, section titles, and body copy like a real product. Avoid centered hero-style marketing headings inside app screens.
- **State Coverage**: Every view must explicitly handle:
  1. **Loading State**: Subtle inline skeletons or lightweight spinner without tearing down scaffolds.
  2. **Empty State**: Calm, left-aligned or compact icon with concise explanation and direct action.
  3. **Error State**: Non-blocking banner or snackbar with actionable retry.

---

## 4. Realistic Indian College Academic Data
Always use authentic university data patterns rather than placeholder text:
- **Real Subject Names**:
  - `Data Structures & Algorithms Lab (CS3101)`
  - `Computer Networks Lab (CS3102)`
  - `Database Management Systems Lab (CS3103)`
  - `Operating Systems Lab (CS3104)`
  - `Digital Electronics Lab (EC3101)`
- **Roll Numbers & Sections**:
  - Registration: `21BCE1001`, `21BCE1042`, `22BCSE088`, `20BIT015`
  - Sections: `CSE-5B`, `CSE-5A`, `ECE-3C`
- **Uneven Text Lengths**: Realistic experiment titles (e.g. *“Implementation of AVL Tree Rotations and Deletion Algorithms”* vs *“SQL Queries”*).
- **Teacher Remarks in Plain Language**:
  - *"Medical certificate from Apollo Clinic verified for viral fever on 12-Oct. Cleared."*
  - *"Syllabus alignment confirmed. Experiment 4 (Binary Search Trees) repetition approved."*
  - *"Lab capacity verified. Seat 18 assigned in Batch B2 on Thursday 2-4 PM."*
  - *"Cleared by HOD office. Quota verified."*

---

## 5. Screen-Specific Archetypes & Inspirations
- **Google Classroom**: Overall calm tone, header banners, dense announcements/assignments stream with hairline separators.
- **Linear**: Dense list rows, muted metadata, compact key-value lines, small 6px dot status indicators.
- **Google Calendar**: Structured 5-day / 6-period timetable grid with clear lab session blocks and conflict markers.
- **Swiggy Order Tracking**: Clean vertical approval stepper with continuous line, subtle check dots, timestamps, approver names, and plain-language remarks.
