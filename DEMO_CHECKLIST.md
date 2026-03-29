# Video Demo Checklist

This document tracks all required actions for the 10-15 minute demo video submission.
Use this as a run-sheet before and during recording.

---

## Recording Rules

- Single, continuous recording (no cuts, no speed-ups)
- Run on a physical device or emulator (NOT web or desktop)
- Resolution 1080p or higher, audio clear with no echo
- No team member introductions, go straight to the app
- Every member must speak and demonstrate at least one feature

---

## Required Actions (all 7 must appear in the video)

| # | Action | Notes |
|---|---|---|
| 1 | **Cold-start launch** | Close app fully, reopen, show splash/load sequence |
| 2 | **Register, logout, and login** | Register a new account, log out, then log back in |
| 3 | **Visit every screen and rotate once** | Home, Search Results, Provider Profile, Booking, Dashboard, Settings, Profile |
| 4 | **Full CRUD with Firebase Console visible** | Create a booking, read it in Firestore, update its status, delete/cancel it |
| 5 | **State update touching two widgets** | Accept a booking and show both the booking card and the earnings balance update |
| 6 | **SharedPreferences: change setting, restart, verify persistence** | Toggle dark mode, force-close app, reopen and confirm theme is still applied |
| 7 | **Trigger a validation error** | Submit login with empty fields and show the snack bar message |

---

## Suggested Screen Order for Demo

1. Open app (cold start)
2. Register as a Client
3. Browse home screen, tap a category
4. Open a provider profile
5. Create a booking (show Firestore Console update live)
6. Log out
7. Log back in as a Provider
8. Open Provider Dashboard, accept/cancel the booking (show Firestore update)
9. Navigate to Settings, toggle dark mode
10. Force-close app, reopen, confirm dark mode persisted
11. Go back to login screen, submit with empty fields (validation error)

---

## Hand-off Points (who demonstrates what)

| Member | Feature to Demonstrate |
|---|---|
| Member 1 | Authentication flow (register, login, logout) |
| Member 2 | Provider dashboard and CRUD operations with Firebase Console |
| Winnie-Irene | SharedPreferences persistence, search, and validation errors |

---

## Pre-recording Checklist

- [ ] App runs without errors on emulator or physical device
- [ ] Firebase Console is open and logged in on a second screen
- [ ] Screen recording software is set to 1080p or higher
- [ ] Microphone tested, no background noise
- [ ] All team members are available and know their section