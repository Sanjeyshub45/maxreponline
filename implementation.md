
---

# 📄 Product Requirements Document (PRD)

**Product Name:** MaxRep (Working Title)
**Platform:** Mobile (iOS & Android)
**Tech Stack:** Flutter, Firebase (Auth, Firestore, Cloud Functions), Strava API

## 1. Product Vision & Objective

**The Problem:** Most fitness leaderboards (like Strava or Apple Fitness) only reward absolute performance (speed, distance, weight lifted). This discourages beginners, heavier individuals, and casual users from participating in group fitness challenges.
**The Solution:** MaxRep is a gamified health and social fitness platform that ranks users using a **BMI-Adjusted Performance Score**. By leveling the playing field using relative effort and hierarchical leaderboards (Colleges, Companies, Districts), it turns personal health into a fair, community-driven sport.

## 2. Target Audience

* **Corporate Employees & HR Teams:** Looking for internal wellness challenges where the "IT guy" can fairly compete against the "Sales marathon runner."
* **College Students:** Seeking gamified, tribal competition against rival dorms, departments, or universities.
* **General Fitness Enthusiasts:** Users who love the social logging of apps like *Hevy* but want a unified health score.

## 3. Core Features & Functional Requirements

### 3.1 Onboarding & "Tribe" Affiliation

* **User Authentication:** Sign up via Email/Password or Google/Apple OAuth (handled via Firebase Auth).
* **Bio-Profile Setup:** Users input Age, Gender, Height, and Weight. The app calculates their baseline BMI.
* **Hierarchy Selection:** Users select their affiliations:
* *Organization:* Company (e.g., Google) or College (e.g., MIT). Verification via email domain.
* *Geolocation:* District, State, and Country.



### 3.2 Data Ingestion & Integrations

* **Automated Cardio (Strava):** Integration with Strava API v3. Webhooks ping Firebase Cloud Functions when a user completes a run, ride, or swim.
* **Automated Steps (HealthKit/Google Fit):** Background syncing of daily steps to calculate the "Consistency" score.
* **Manual Strength Check-in:** A weekly prompt asking for max unbroken Pushups to calculate the "Relative Strength Index."

### 3.3 The Scoring Engine (The "Pulse Score")

Calculated server-side via Firebase Cloud Functions to prevent cheating.

* **The Formula:** 
$$Final Score = (Activity \times 40\%) + (Strength \times 30\%) + (Vitality/Consistency \times 30\%)$$


* **The BMI Multiplier:** Users with a BMI > 25 (or outside their gender's ideal range) receive an "Effort Multiplier" (e.g., $1.2\times$ to $1.5\times$) on cardio activities, rewarding the extra mass moved.
* **The Gender Equity Bonus:** Women receive a $1.25\times$ multiplier on pushup scores to account for biological differences in upper-body muscle distribution.

### 3.4 Hierarchical Leaderboards

* **Dynamic Views:** Users can filter leaderboards by:
* Global
* Location (State -> District)
* Organization (Company/College -> Department)
* Weight Class (e.g., "Heavyweight Division" for BMI > 30)


* **Real-time Updates:** Powered by Firestore `StreamBuilder`, leaderboards update instantly when points change.

### 3.5 Social Feed & AI Coaching

* **The "Pulse Feed":** A scrolling feed showing friends' logged workouts, rank-ups, and milestone badges. Users can give "Kudos" and comment.
* **Actionable Tips:** Automated contextual advice. *Example: "You dropped to #4 in the Marketing Dept. Log 5,000 steps today to reclaim the #3 spot!"*

## 4. Technical Architecture (Non-Functional Requirements)

| Component | Technology / Implementation |
| --- | --- |
| **Frontend UI** | Flutter (Dart) for cross-platform iOS and Android apps. |
| **Database** | Firebase Cloud Firestore (NoSQL). Denormalized structure for rapid leaderboard querying. |
| **Backend Logic** | Firebase Cloud Functions (Node.js). Secures the scoring algorithm and handles Strava webhooks. |
| **Security Rules** | Firestore Rules ensure users can read leaderboards but cannot manually write/edit their `pulse_points`. |
| **Storage** | Firebase Storage for user profile pictures and optional verification media. |

## 5. User Journey Flow

1. **Sign Up:** User enters bio-data and joins "Acme Corp" and "Downtown District."
2. **Connect:** User links their Strava account.
3. **Action:** User goes for a 3km run.
4. **Processing:** Strava pings Firebase. The Cloud Function applies the user's BMI multiplier and calculates 450 Pulse Points.
5. **Update:** User climbs 5 spots on the Acme Corp leaderboard.
6. **Social:** A post automatically drops in the Acme Corp feed: *"Alex just crushed a 3km run and moved to Rank #12!"* Coworkers leave Kudos.

## 6. Future Scope (Phase 2)

* **Verified Lifting:** Video uploads for strength metrics evaluated by AI or community voting to prevent false manual entries.
* **Camera-based Vitals (PPG):** Using the smartphone camera to measure Resting Heart Rate (RHR) and Heart Rate Variability (HRV) for a deeper Vitality Score.
* **B2B Admin Dashboards:** Paid portals for HR managers to view anonymized company health trends and sponsor internal rewards.