# SolBuddy Madrid — Demo Script

**Total runtime: ~5 minutes**

---

## Opening Hook (30 sec)

> "Madrid hits 40 °C in summer. Most people have no idea where to find shade, a fountain, or an air-conditioned building nearby — and there's nothing that motivates them to care. SolBuddy fixes that by turning heat-awareness into a game."

---

## 1. Login / Register (30 sec)

**What to show:** Launch the app cold.

- The app opens on the **Login screen** — clean, branded "SolBuddy Madrid".
- Tap **"Register"** → fill in a name, email, password → hit **Register**.
- Firebase Auth creates the account instantly; the app transitions to the main shell.

**Talking point:**
> "Accounts are backed by Firebase — progress is saved across devices from day one."

---

## 2. Home Screen — Meet Sol (60 sec)

**What to show:** The Home tab is the first thing users see after login.

- Point out the **Sol avatar** at the top — a sun character whose mood reflects your XP.
  - At 0 XP Sol is **Melting** — sad, drooping.
  - Explain the stages: Melting → Hot → Warm → Cool → Radiant (100+ XP).
- Below the avatar: the **XP bar** shows progress toward the next stage and the current stage label (e.g. "MELTING").
- Three **stat cards** below: Streak, Cool Spots visited, Quizzes completed.
- At the bottom: a **weather card** pulling live data from Open-Meteo.
  - Shows the current Madrid temperature and a heat label (e.g. "Comfortable", "Hot", "Extreme Heat").
  - **Key mechanic:** if it's above 34 °C today, Sol's displayed XP is penalised in real time — the avatar looks sadder. This creates urgency.

**Talking point:**
> "Sol is a living feedback loop. The hotter Madrid gets, the worse Sol feels — and the only way to help Sol is to take real-world cooling actions."

---

## 3. Map Screen — Heat Map (45 sec)

**What to show:** Tap the **Map** tab in the bottom nav.

- An OpenStreetMap view of Madrid loads with **8 colour-coded district markers**.
  - Each marker shows the live temperature for that district (e.g. "38°").
  - Colours range from green (comfortable) to red (extreme heat).
- A **blue GPS dot** shows the user's current location.
- Tap any district marker → a snackbar pops up: `"Centro: 37.2 °C — Hot"`.
- Pull down to refresh all district temperatures live.

**Talking point:**
> "We batch all 8 district requests to the Open-Meteo API — no API key needed, completely free."

---

## 4. Cool Spots — Check In for XP (60 sec)

**What to show:** Tap the **Cool Spots** tab.

- **List view** by default: 10 real Madrid locations (parks, fountains, AC buildings, shaded areas).
  - Examples: Parque del Retiro, Fuente de Cibeles, CaixaForum, El Corte Inglés Callao.
  - A chip in the top-right shows `0 / 10` visited.
- Tap **"Check in"** on *Parque del Retiro*.
  - A snackbar appears: **"+5 XP — checked in!"**
  - The row immediately shows a green check icon. Counter updates to `1 / 10`.
- Toggle to **Map view** using the segmented button at the top.
  - All 10 spots appear as markers on a Madrid map.
  - Orange = not visited, Green = visited.
  - Tap a marker → a bottom sheet shows the spot name and type, with a Check-in button (or "Already visited" chip).

**Talking point:**
> "Check-ins are the biggest XP earner — +5 XP each. Visiting a cool spot in the real world helps both Sol and the user."

---

## 5. Quiz — Earn XP with Knowledge (60 sec)

**What to show:** Tap the **Quiz** tab.

- The start screen explains: *"Answer 3 questions about heat, health, and solutions to earn XP for Sol!"*
- Tap **Start Quiz**.
- Each question shows a **cube badge** (Heat / Health / Solutions) and a progress bar.
- Answer all 3 questions — tap an option:
  - Correct → tile turns green with a ✓ icon.
  - Wrong → tile turns red with an ✗, correct answer highlighted in green.
  - Tap **Next** to advance.
- After question 3, tap **See Result**.
- **Result screen** shows: `2 / 3 correct` and `+4 XP` (or `3 / 3` → `+9 XP` with perfect bonus).

**Talking point:**
> "One quiz session per day keeps it from being grindy. A perfect round gives a +3 XP bonus on top of the +2 per correct answer."

---

## 6. Profile — Stats & Leaderboard (30 sec)

**What to show:** Tap the **Profile** tab.

- A card at the top shows the user's name initial, total XP, streak, spots visited, and quizzes played — all in one line.
- Below that: a **Leaderboard** pulled from Firestore, ranking all players by XP.
  - The current user's row is highlighted in the primary container colour.
- **Sign Out** button at the bottom.

**Talking point:**
> "The leaderboard is social proof — seeing friends above you is the best motivation to go find a fountain."

---

## Closing (30 sec)

> "SolBuddy turns a public health problem — urban heat — into something people actually want to engage with. Daily logins, streaks, quiz knowledge, and real-world check-ins all feed back into Sol's wellbeing. The more you beat the heat, the happier Sol gets."

**Show the Home screen one final time with Sol now at a higher XP stage after the demo actions.**

---

## Demo Reset Checklist

Before the demo, set up a fresh account (or use a test account with low XP) so Sol starts in the **Melting** stage and the transformation is visible during the session.

| Action during demo     | XP gained |
|------------------------|-----------|
| Account created (daily login) | +1 |
| 1 cool spot check-in   | +5        |
| 2/3 quiz correct       | +4        |
| **Total**              | **+10 XP** → Sol reaches **Hot** stage |

For a more dramatic arc, check in 2 spots (+10 XP) and get a perfect quiz (+9 XP) to push Sol all the way to **Warm** (30+ XP).
