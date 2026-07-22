# G-TEC Admin Console — Production Readiness Audit

**Audited:** 2026-07-22  
**Repo root:** `/workspace`  
**Branch audited:** `main` @ `5554fa7`  
**Scope:** Every file under `lib/`, `test/`, `web/`, `pubspec.yaml`, `README.md`, git history (2 commits).  

**Verdict up front:** This repository is a **Flutter Web UI prototype** that recreates an admin console design with **hardcoded mock data**. There is **no backend, no database, no authentication, no student app, and no real role enforcement**. It is **not** a production product and **cannot** go live as a working education platform within 2 days.

---

## STEP 1 — Repository Overview

### What product this repository is building

Per `README.md` L1–3 and `pubspec.yaml` L1–2: **G-TEC Education · Admin Console** — a pixel-perfect Flutter recreation of a web admin design covering **11 screens**. It is explicitly a design recreation, not a full LMS.

There is **no** student-facing learning app, teacher grading workflow backend, payment processor, or CMS server in this repo.

### Tech stack

| Layer | Reality in repo |
|---|---|
| Language | Dart (`sdk: ">=3.3.0 <4.0.0"`, `pubspec.yaml` L6–7) |
| UI | Flutter (web-only platform folder present: `web/`; `.metadata` migration lists only `web`) |
| State | `provider` ^6.1.2 + `ChangeNotifier` controllers |
| Fonts | `google_fonts` ^6.2.1 |
| Icons | `flutter_svg` ^2.0.10+1 |
| HTTP / API client | **Not Implemented** (no `http`, `dio`, etc. in `pubspec.yaml`) |
| Backend | **Not Implemented** |
| Database | **Not Implemented** |
| Auth | **Not Implemented** |
| CI/CD | **Not Implemented** (no `.github/`, Docker, Vercel/Netlify config) |

### Frameworks

- Flutter MaterialApp (`lib/main.dart` L45–51)
- Named routes via `onGenerateRoute` (`lib/routes/app_router.dart`)
- MVC-style folders: `models/`, `controllers/`, `views/` (`README.md` L35–54)

### Database

**Not Implemented.** No SQL/NoSQL schema, migrations, seed files, SQLite, Postgres, Supabase, Firebase, or local persistence packages.

### Authentication

**Not Implemented.** App boots straight to Dashboard with no login gate (`lib/main.dart` L49: `initialRoute: AppRoutes.dashboard`). Sidebar “users” are static display objects in `NavPresets` (`lib/views/widgets/nav_presets.dart` L154–170).

### APIs

**Not Implemented.** `README.md` L45 and L70–72 state `core/services/` is “reserved for API layer” and controllers hold design data as plain lists. Directory `lib/core/services/` **does not exist**.

### Third-party integrations

| Integration | Status |
|---|---|
| Google Fonts (runtime download) | Present via `google_fonts` |
| YouTube (curriculum UI shows a link string) | Display-only mock (`CurriculumController` / screen UI) |
| Payment gateway (Razorpay/Stripe/etc.) | **Not Implemented** |
| Email / Push / SMS | **Not Implemented** (broadcast UI is fake) |
| OAuth / SSO | **Not Implemented** |
| Analytics (GA, Mixpanel, etc.) | **Not Implemented** |
| Error tracking (Sentry, etc.) | **Not Implemented** |

### Deployment architecture

- **Web only** in tree: `web/index.html`, `web/manifest.json`, icons.
- **No** `android/`, `ios/`, `macos/`, `linux/`, `windows/` folders.
- **No** Docker, Nginx, GitHub Actions, hosting config.
- README says `flutter run -d chrome` (`README.md` L12–15).
- Production deployment config: **Not Implemented.**

### Folder structure (actual)

```
lib/
├── core/           constants, theme, utils, widgets  (NO services/)
├── models/         12 plain Dart data classes (no fromJson/toJson)
├── controllers/    11 ChangeNotifier classes with hardcoded lists
├── views/
│   ├── layouts/    admin_shell.dart
│   ├── widgets/    sidebar, top bar, nav_presets, shared_widgets
│   └── screens/    11 screens
├── routes/         app_routes.dart, app_router.dart
└── main.dart
test/widget_test.dart   (broken default counter test)
web/                    Flutter web host
```

Also committed historically: `.dart_tool/` and `build/` artifacts (first commit) — tooling noise, not product code.

### Current development stage

**UI prototype / design handoff stage** (visual MVC shell).  
Git history: 2 commits (`109e478` first commit, `5554fa7` minor screen/theme/web scaffolding). ~6.9k lines of Dart under `lib/`.

---

## STEP 2 — Feature Completion Audit

Statuses reflect **production-usable product capability**, not “does a painted screen exist.”

| Feature | Status | Completion % | Issues | Priority |
|---|---|---|---|---|
| Admin UI shell (sidebar + top bar) | Completed (UI) | 90% | Persona nav hard-coded per screen; no real session | Medium |
| Analytics Dashboard | Partial (UI mock) | 70% | Hardcoded KPIs/charts (`dashboard_controller.dart` L8–69); search/bell dead | High |
| Curriculum Builder (CMS) | Partial (UI mock) | 55% | Local expand/publish toggles only; Add module/lesson/upload/drag dead | High |
| Pricing Manager | Partial (UI mock) | 45% | Segment toggle UI-only; prices not editable; Save dead | High |
| Assessment Engine | Partial (UI mock) | 40% | One hardcoded question; Add/Save/Publish/edit dead | High |
| Team & Roles display | Partial (UI mock) | 35% | Static members + matrix; Invite dead; no RBAC enforcement | Critical |
| Teacher Console screen | Partial (UI mock) | 30% | Grade/New assignment/Start live dead; 4 nav items route=null | High |
| Student Management | Partial (UI mock) | 40% | Filters/pagination don’t change list; Add/search dead | High |
| Live Class Scheduler | Partial (UI mock) | 35% | Audience chip only; Schedule/Save dead; form not editable | High |
| Notifications / Broadcast | Partial (UI mock) | 30% | Channel/audience chips only; **Send broadcast not tappable** (`notifications_screen.dart` L284–304) | High |
| Payments & Leads | Partial (UI mock) | 35% | Filter chips don’t filter; Export/row-click promised but missing | High |
| Growth & Insights | Partial (UI mock) | 40% | Read-only mock charts/tables; date filter dead | Medium |
| Authentication | Missing | 0% | No login/signup/reset | Critical |
| Authorization / RBAC | Missing | 0% | Roles are labels in mock data only | Critical |
| Landing page / marketing site | Missing | 0% | Not in repo | Low |
| Student Portal / app | Missing | 0% | Not in repo | Critical |
| Teacher Portal (real) | Missing | 5% | One mock screen only | Critical |
| Admin Portal (real) | Partial UI | 15% | Painted screens, no backend | Critical |
| Super Admin Portal (real) | Partial UI | 15% | Same | Critical |
| Course Management (persist) | Missing | 10% | UI mock only | Critical |
| Assignments (real) | Missing | 0% | Teacher CTA dead; no model CRUD | High |
| Certificates | Missing | 0% | Not Implemented | Medium |
| Payments (gateway + ledger) | Missing | 5% | Fake table only | Critical |
| Notifications (delivery) | Missing | 5% | Composer UI only | High |
| Messaging / Doubts | Missing | 0% | Teacher nav item has `route: null` | Medium |
| Settings | Missing | 0% | Not Implemented | Medium |
| Reports (real) | Missing | 5% | Dashboard/Growth are fake numbers | High |
| Analytics (real) | Missing | 5% | Hardcoded bars/donut/funnel | High |
| File Upload | Missing | 0% | Dashed upload zone is decorative | High |
| Search | Broken / Missing | 5% | `AppSearchField` present without handlers on screens | Medium |
| Profile | Missing | 0% | Sidebar user is static | Medium |
| Email | Missing | 0% | Not Implemented | High |
| OTP | Missing | 0% | Not Implemented | Medium |
| Role Management (enforce) | Missing | 0% | Matrix is display-only (`team_controller.dart` L38–64) | Critical |
| Permissions (enforce) | Missing | 0% | No middleware/guards | Critical |
| Attendance | Missing | 0% | Not Implemented | Medium |
| Internship Management | Missing | 0% | Not in product scope of this repo | — |
| Reviews | Partial (UI mock) | 20% | Hardcoded in `growth_controller.dart` | Low |
| Blog | Missing | 0% | Not Implemented | Low |
| CMS (real content store) | Missing | 10% | Curriculum screen is mock | Critical |
| API layer | Missing | 0% | No services, no endpoints | Critical |
| Database | Missing | 0% | Not Implemented | Critical |
| Cron Jobs | Missing | 0% | Not Implemented | Medium |
| Background Workers | Missing | 0% | Not Implemented | Medium |
| Webhooks / Edge functions | Missing | 0% | Not Implemented | Medium |

**UI visual completeness for the 11 designed screens:** ~85–95%.  
**End-to-end product completeness:** ~**8–12%**.

---

## STEP 3 — Role Based Functionality Audit

**Important:** There are no separate authenticated apps. Each screen **hardcodes** which `NavPresets` + `SidebarUser` to show (e.g. Content Admin vs Teacher). Anyone who can open the web app can navigate to every route via URL/`pushReplacementNamed` — `AppRouter` has **no auth checks** (`app_router.dart` L19–33).

### Student / User

| Capability | Works? | Evidence |
|---|---|---|
| Register | No | Not Implemented |
| Login | No | Not Implemented |
| Reset password | No | Not Implemented |
| Edit profile | No | Not Implemented |
| Enroll | No | Not Implemented |
| Access dashboard | No student dashboard | Admin-only console |
| Submit assignments | No | Not Implemented |
| Download certificates | No | Not Implemented |
| View progress | No | Students table shows fake `%` strings only |
| Receive notifications | No | Not Implemented |

**Students cannot use this product today.** Only an admin UI lists mock student rows (`students_controller.dart`).

### Teacher

| Capability | Works? | Evidence |
|---|---|---|
| Login | No | Persona painted on `/teacher` (`teacher_screen` + `NavPresets.menonTeacher`) |
| Manage students | No | Not Implemented |
| Upload assignments / lessons | No | Nav items `Upload lesson`, `Assignments` have **null route** (`nav_presets.dart` L59–62); CTAs have no `onTap` |
| Review submissions | No | “Grade” buttons dead |
| Issue certificates | No | Not Implemented |
| Track attendance | No | Not Implemented |
| Create courses | No | Not Implemented |
| View reports | UI only | Fake KPIs on teacher screen |
| Start live class | No | Button dead |
| Doubts | No | Nav item route null |

**Teachers cannot operate a real workflow today.** Only a static console painting exists.

### Admin

| Capability | Works? | Evidence |
|---|---|---|
| Manage users/students | UI only | List mock; Add student dead; filters don’t filter |
| Manage teachers | UI only | Shown in Team table; Invite dead |
| Manage courses | UI only | Curriculum toggles are local memory only |
| Manage payments | UI only | Fake ledger; Export dead |
| Manage certificates | No | Not Implemented |
| Manage settings | No | Not Implemented |
| View analytics | UI only | Hardcoded dashboard/growth |
| Schedule live class | UI only | Audience chip local; Schedule dead |
| Send notifications | No | Send control is non-interactive container |

### Super Admin

| Capability | Works? | Evidence |
|---|---|---|
| System control | No | Not Implemented |
| User management | UI mock | `TeamController.members` static |
| Role management | Display only | Permission matrix not editable/enforced |
| Database management | No | No database |
| Global settings | No | Not Implemented |
| Audit logs | No | Not Implemented |
| Permission control | No | Booleans in mock list only |
| Analytics | UI mock | Growth/Payments screens |

---

## STEP 4 — Frontend Audit

### Screens present (all route)

| Route | Screen file | Visual | Functional |
|---|---|---|---|
| `/dashboard` | `dashboard_screen.dart` | Complete mock | Read-only fake data |
| `/curriculum` | `curriculum_screen.dart` | Complete mock | Expand/publish/preview toggles only |
| `/pricing` | `pricing_screen.dart` | Complete mock | Segment highlight only |
| `/assessments` | `assessment_screen.dart` | Complete mock | Two toggles only |
| `/team` | `team_screen.dart` | Complete mock | Read-only |
| `/teacher` | `teacher_screen.dart` | Complete mock | Dead CTAs; incomplete nav |
| `/students` | `students_screen.dart` | Complete mock | Filter/page highlight only |
| `/live-classes` | `scheduler_screen.dart` | Complete mock | Audience select only |
| `/notifications` | `notifications_screen.dart` | Complete mock | Chips only; Send dead |
| `/payments` | `payments_screen.dart` | Complete mock | Filter highlight only |
| `/growth` | `growth_screen.dart` | Complete mock | Read-only |

Unknown routes fall through to Dashboard (`app_router.dart` L32).

### Broken / incomplete / dead UI (concrete)

1. **Dead primary actions** (buttons without `onTap`): Add module, Save changes, Save draft, Publish, Invite member, New assignment, Start live class, Grade, Add student, Save draft / Schedule & notify, Export CSV, This month, Last 30 days — across respective screens.
2. **Send broadcast** looks like a button but is a plain `Container` with **no gesture** (`notifications_screen.dart` L284–304).
3. **Teacher nav dead ends:** My classes, Upload lesson, Assignments, Doubts (`nav_presets.dart` L59–62` + `admin_shell.dart` L39–40 early return).
4. **Forms are not forms:** `InputBox` / `DropdownBox` render static text (`app_inputs.dart`); curriculum/assessment/scheduler fields are non-editable displays.
5. **Filters that don’t filter:** Students, Payments (`setFilter` updates index only).
6. **Pagination that doesn’t paginate:** Students `setPage` + dead chevron buttons; copy hardcoded “Showing 1–5”.
7. **Pricing cells look editable, are `Text`** (`pricing_screen.dart` `_PriceCell`).
8. **Payments footer claims row click opens profile** — rows have no `onTap`.
9. **NotificationBell** has no tap handler (`app_top_bar.dart`).
10. **Search fields** present without query logic on Dashboard/Students.
11. **Drag to reorder** claimed in curriculum copy — no drag implementation.
12. **Upload zone / YouTube / PDF** decorative placeholders.
13. **Broken test:** `test/widget_test.dart` still references `MyApp` and counter — app class is `GtecAdminApp` (`main.dart` L26). Test will fail.
14. **Responsive:** Desktop-first; below 1100px sidebar → drawer (`admin_shell.dart` L47–87, `responsive.dart`). Wide tables force horizontal scroll (e.g. payments width 1100). Mobile is secondary; not a native app.
15. **Accessibility:** No `Semantics` usage under `lib/`; icon-only controls unlabeled; custom radios without roles.
16. **Placeholder web metadata:** `web/index.html` / `manifest.json` still say “A new Flutter project.” / `gtec_admin`.

---

## STEP 5 — Backend Audit

**There is no backend in this repository.**

| Expected artifact | Finding |
|---|---|
| API routes / controllers / services | **Not Implemented** |
| Middleware | **Not Implemented** |
| Database queries | **Not Implemented** |
| Validation layer | **Not Implemented** |
| Auth functions | **Not Implemented** |
| Cron / workers / webhooks / edge functions | **Not Implemented** |
| `lib/core/services/` | **Missing** (README reserves it) |

All “business logic” is in-memory UI state in Flutter controllers (toggles/chips). No persistence survives refresh.

---

## STEP 6 — Frontend ↔ Backend Synchronization

Every screen uses **hardcoded controller data**. None call a backend.

| Page | Connection status | Detail |
|---|---|---|
| Dashboard | Hardcoded / Fake data | `DashboardController` const KPIs/charts (`L10–69`); comment says swap with API later (`L8`) |
| Curriculum | Hardcoded + local UI state | Modules list const; toggle expands locally |
| Pricing | Hardcoded + local UI state | Items const; segment doesn’t change data |
| Assessments | Hardcoded + local UI state | One question; toggles only |
| Team | Hardcoded | Members + permissions const |
| Teacher | Hardcoded | KPIs/submissions/live const |
| Students | Hardcoded + fake filter/page | List never filtered/paged |
| Scheduler | Hardcoded + local audience | Form strings const |
| Notifications | Hardcoded + local chips | No send API |
| Payments | Hardcoded + fake filter | Rows const |
| Growth | Hardcoded | KPIs/funnel/reviews const |

| Sync concern | Status |
|---|---|
| Connected to real API | **0 / 11 screens** |
| Mock / fake / hardcoded | **11 / 11** |
| Wrong endpoint | N/A (no endpoints) |
| Missing endpoint | **All product actions** |
| Missing database | **Yes** |
| Missing validation | **Yes** |
| Missing permissions | **Yes** |

---

## STEP 7 — Database Audit

| Item | Finding |
|---|---|
| Schema | **Not Implemented** |
| Relations / FKs / indexes / constraints | **Not Implemented** |
| RLS | **Not Implemented** |
| Migrations / seeds | **Not Implemented** |
| Models serialization | No `fromJson`/`toJson` on any model |
| Unused tables | N/A |

Models exist only as Flutter UI DTOs (`lib/models/*.dart`).

---

## STEP 8 — Authentication Audit

| Item | Status | Evidence |
|---|---|---|
| Login / Signup | Missing | No screens/routes |
| OAuth | Missing | — |
| JWT / session tokens | Missing | — |
| Supabase Auth / Firebase Auth | Missing | Not in dependencies |
| Session management | Missing | — |
| Role protection | Missing | Personas painted, not enforced |
| Middleware / route guards | Missing | `AppRouter` maps name → screen only |
| Token refresh | Missing | — |
| Logout | Missing | — |
| Password reset | Missing | — |
| Email verification | Missing | — |
| Permission checks | Missing | Matrix is decorative |

**Security implication:** The entire admin console is publicly reachable if hosted as static Flutter web.

---

## STEP 9 — Security Audit

| Finding | Severity | Why |
|---|---|---|
| No authentication on admin console | **Critical** | Full admin UI open if deployed |
| No authorization / privilege escalation trivially possible | **Critical** | Any route accessible; roles are UI labels |
| No backend input validation / authz | **Critical** | When API is added later, currently zero patterns exist |
| Hardcoded PII-like mock emails/phones in client | **Medium** | e.g. `aarav.s@gmail.com`, `+91 98765 43210` in payments controller — demo data ships in bundle |
| Fake `@gtec.edu` staff emails in client | **Low** | `team_controller.dart` L11–35 |
| XSS via Flutter web | **Low–Medium** | Mostly static Text; risk rises when user HTML/content is wired without sanitization |
| CSRF / SQLi | N/A today | No backend; must be designed when API appears |
| Hardcoded secrets / API keys in repo | **None found** | Grep: no tokens/keys; deps have no cloud SDKs |
| Sensitive logging | **None found** | No logging layer |
| File upload vulns | **N/A (UI fake)** | Real upload not implemented |
| Rate limiting | **Missing** | No API |
| `.dart_tool` / build artifacts historically committed | **Low** | Bloat / accidental leak surface for tooling caches |
| google_fonts network dependency at runtime | **Low** | Offline/privacy/CDN dependency |

---

## STEP 10 — Performance Audit

| Area | Finding |
|---|---|
| Bundle | Flutter web apps are relatively large by default; no code-splitting strategy beyond Flutter’s defaults; only one MaterialApp |
| Duplicate providers | All 11 controllers created at app root (`main.dart` L32–43) even when unused on a screen — fine for mock size, wasteful later |
| Infinite re-render | No obvious loops; mostly static trees |
| N+1 queries | N/A (no DB) |
| Pagination | UI fake; would load full lists if wired naively |
| Charts | Custom painters with `TweenAnimationBuilder` — acceptable for demo |
| Images | Hatch placeholders (`HatchAvatar`); no large media assets in repo |
| Caching | None |
| Google Fonts | Runtime fetch can delay first paint |

No production performance profiling artifacts in repo.

---

## STEP 11 — Code Quality Audit

| Finding | Evidence |
|---|---|
| Clean UI architecture for a prototype | Clear MVC folders, shared widgets, theme tokens |
| Dead / reserved architecture | `core/services/` promised, absent |
| Models not API-ready | No serialization |
| Controllers mix “design fixtures” with tiny UI state | e.g. payments filter doesn’t filter rows |
| Duplicate nav presets | Multiple overlapping admin personas instead of one RBAC-driven menu |
| Broken default test | `test/widget_test.dart` |
| Naming | Generally clear (`GtecAdminApp`, screen names) |
| Typing | Sound Dart models; no Freezed/json_serializable |
| State management | Provider OK for UI; insufficient for offline/sync/auth |
| Technical debt | Entire persistence/auth/API layers deferred by design (`README.md` L70–72) |
| Repo hygiene | First commit included huge `.dart_tool`/`build` binaries; later `.gitignore` added |

---

## STEP 12 — Deployment Readiness

| Item | Status |
|---|---|
| Docker | Missing |
| CI/CD / GitHub Actions | Missing |
| Env vars / secrets management | Missing (and unused) |
| Production config | Missing |
| Build scripts beyond Flutter defaults | Missing |
| Vercel / Netlify / Cloudflare config | Missing |
| Nginx | Missing |
| Monitoring / logging / backups / error tracking | Missing |
| Platforms | **Web folder only** — README claims android/ios/desktop but those folders are absent |

**Can you deploy production today?**  
You can run `flutter build web` and host static files as a **clickable design demo**. You **cannot** deploy a production education product (no auth, no data, no APIs).

**Production deployment rating for a real product: Not possible today.**

---

## STEP 13 — Testing Audit

| Type | Status |
|---|---|
| Unit tests | **Missing** |
| Integration tests | **Missing** |
| E2E tests | **Missing** |
| Widget tests | **Broken** — still Flutter counter template (`test/widget_test.dart` references `MyApp`) |
| Coverage | Effectively **0%** |

Critical untested areas: everything (navigation, controllers, forms, future API).

---

## STEP 14 — Current Blocking Issues

### Critical (block any real launch)

1. **No backend / API** — nothing persists or integrates.
2. **No database** — no source of truth.
3. **No authentication** — admin surface cannot be exposed.
4. **No authorization** — roles are cosmetic.
5. **No student product** — learners cannot use the system.
6. **Primary CTAs are no-ops** — Save/Publish/Send/Schedule/Invite/Grade/Export do not work.
7. **Teacher workflows missing** — nav stubs with `route: null`.

### High

8. Forms are non-editable displays (`InputBox`/`DropdownBox`).
9. Filters/pagination cosmetic only.
10. File upload not implemented.
11. Payments not connected to any gateway/ledger.
12. Notifications cannot send.
13. Broken automated test / no test suite.
14. No CI/CD or production hosting pipeline.
15. Web-only; native folders not present despite README wording.

### Medium

16. Accessibility gaps (no Semantics).
17. Placeholder web manifest/title.
18. Demo PII strings baked into client.
19. google_fonts runtime dependency.

### Low

20. Historical commit of build tooling artifacts.

---

## STEP 15 — Can this become LIVE within 2 days?

# NO

**Not as a working production education product.**

What exists is a high-fidelity **admin UI demo**. A production LMS/admin platform requires backend, auth, DB, real CRUD, payments, notifications, and at least one learner experience — **none of which exist in this repo**.

| If goal is… | 2-day feasible? |
|---|---|
| Host static Flutter web as **investor UI demo** (clearly labeled mock) | **YES with conditions** |
| Launch usable product for students/teachers/admins with real data | **NO** |

### What must be completed for a *demo* host (not production)

- Fix/remove broken widget test; `flutter build web`
- Add basic hosting + cache headers
- Banner: “Demo — mock data”
- Optionally strip or anonymize fake PII strings  
**Who:** 1 Flutter/web engineer  
**Estimated hours:** 4–8  
**Dependencies:** Flutter SDK, static host  
**Risks:** Stakeholders may mistake UI for working product

### What must be completed for *real* production (far beyond 2 days)

- Auth + RBAC, API, DB schema, wire all 11 screens, student app, payments, notifications, uploads, tests, CI/CD, monitoring  
**Estimated engineering:** multi-week / multi-person (order of **200–500+ engineer-hours** depending on scope), not 48 hours

---

## STEP 16 — Priority Roadmap

Hour estimates are engineering effort for a competent full-stack + Flutter team.

### Must Finish Today (if aiming only for honest demo)

| Task | Hours |
|---|---|
| Label app as Demo / Mock Data in UI | 1 |
| Fix or delete broken `widget_test.dart` | 0.5 |
| `flutter build web` + deploy static hosting | 2–4 |
| Remove/replace realistic phone/email fixtures | 1 |
| Update README: “UI prototype, no backend” | 0.5 |

### Must Finish Tomorrow (still demo-hardening, not production)

| Task | Hours |
|---|---|
| Disable or toast all dead CTAs (“Coming soon”) so demos don’t look broken | 4–6 |
| Single unified nav (stop persona-switching illusion) | 3–4 |
| Basic smoke widget tests for routes | 3–4 |
| CI: analyze + test + build web | 2–3 |

### Can Wait (real product foundation)

| Task | Hours |
|---|---|
| Choose backend (e.g. Node/Nest, Supabase) + schema for users/roles/courses/modules/lessons/enrollments/payments | 40–80 |
| Auth (email + session/JWT) + route guards | 24–40 |
| Wire Dashboard/Students/Curriculum read APIs | 40–60 |
| Curriculum write + file upload (S3/R2) | 40–60 |
| Assessments CRUD + attempt engine | 60–100 |
| Scheduler + notification provider (FCM/email) | 40–80 |
| Payments provider + webhook ledger | 60–100 |
| Teacher workflows (grade, assignments, doubts) | 60–100 |
| Student-facing app/web | 120–200+ |
| RBAC enforcement matching Team matrix | 24–40 |
| Observability, backups, rate limits | 24–40 |

### Nice To Have

| Task | Hours |
|---|---|
| Certificates, attendance, blog/CMS marketing, advanced growth analytics | 80–160+ |
| Native iOS/Android admin shells | 40–80 |
| Full a11y pass | 16–24 |

---

## STEP 17 — Developer Productivity Audit

| Waste | Cause | Improvement |
|---|---|---|
| Building pixel UI before API contracts | README admits data is design fixtures | Freeze OpenAPI/schema first; generate models |
| Role UX faked by per-screen nav presets | `NavPresets` duplicates menus | One menu driven by real role claims |
| “Editable” components that aren’t | `InputBox`/`DropdownBox` static | Real `TextFormField` + validation layer |
| Dead buttons with no feedback | Optional `onTap` null | Lint rule / wrapper that asserts handler or shows disabled state |
| Controllers named like domain services but hold consts | Premature MVC without services | Add `core/services` + repositories before more screens |
| Broken template test left in | Copy-paste Flutter create | Fail CI on `flutter test` |
| README claims multi-device run | Only `web/` exists | Generate platforms or correct docs |
| Committing `.dart_tool`/`build` | First commit hygiene | Enforce `.gitignore` (now present) |

---

## STEP 18 — Hidden Problems

1. **`core/services/` documented but missing** (`README.md` L45 vs filesystem).
2. **Teacher secondary screens unreachable** — items intentionally `route: null`.
3. **Role switching is an illusion** — visiting `/teacher` vs `/dashboard` changes painted identity; no login.
4. **Payments UX lie:** footer says click row for profile; not implemented.
5. **Curriculum “drag to reorder” copy** without drag code.
6. **Notification substring(0, 63)** assumes long message (`notifications_screen.dart` L249) — brittle if copy shortens.
7. **Filter methods don’t filter** — easy to mistake for working search during demos.
8. **No `fromJson`** — backend wiring will require model rewrite.
9. **Default unknown route → Dashboard** silently (`app_router.dart` L32) — hides 404s.
10. **Test imports non-existent `MyApp`** — CI would be red if run.
11. **Platform mismatch:** README “android / ios / windows / macos” vs only `web/` in tree.
12. **No env config** — nowhere to put API base URL when backend appears.
13. **All controllers always mounted** — fine now; hides future init/auth sequencing needs.
14. **Growth “refund rate” delta marked positive styling logic** may confuse (deltaPositive false on refund — check product intent).
15. **Web manifest** still generic Flutter template branding.

---

## STEP 19 — Overall Score (0–10)

| Dimension | Score | Note |
|---|---|---|
| Architecture | 4 | Fine UI MVC; no services/domain/data layers |
| Frontend | 7 | Strong visual fidelity for 11 screens |
| Backend | 0 | Absent |
| Database | 0 | Absent |
| Authentication | 0 | Absent |
| Security | 1 | No secrets leaked; also no auth wall |
| Performance | 5 | OK for static demo; unproven at scale |
| Code Quality | 6 | Clean UI code; broken test; fixture-driven controllers |
| Deployment | 2 | Can static-host web; no prod pipeline |
| Scalability | 1 | No server/data plane |
| Documentation | 5 | Honest README about mock wiring; overstates device support |
| Testing | 0 | Broken placeholder only |
| Maintainability | 5 | Good folder layout; will churn when APIs arrive |
| Developer Experience | 5 | Easy to run UI; no API/contracts/CI |
| **Production Readiness** | **1** | Demo-only |

---

## STEP 20 — Final CTO Report

1. **What percentage complete is this project?**  
   - **UI design recreation:** ~90%.  
   - **Production education/admin product:** ~**10%**.

2. **Can users (students) actually use it today?** **No.**

3. **Can teachers use it today?** **No** (cosmetic console only).

4. **Can admins use it today?** **No** for real operations; **Yes** to click through a mock UI locally.

5. **Can super admins use it today?** **No** for real control; mock Team/Growth/Payments screens only.

6. **Is frontend fully connected?** **No.** 0/11 screens connected to a backend.

7. **Is backend complete?** **Not Implemented.**

8. **Is the database production ready?** **Not Implemented.**

9. **Top 20 missing features**  
   1. Auth 2. RBAC enforcement 3. API layer 4. Database 5. Student app 6. Real course CMS persistence 7. Editable forms 8. File uploads 9. Working publish/save 10. Assessment authoring + attempts 11. Live class scheduling + streaming integration 12. Notification delivery 13. Payment gateway + webhooks 14. Lead pipeline actions 15. Teacher grading workflow 16. Assignments/doubts screens 17. Search 18. Audit logs 19. Settings 20. CI/CD + monitoring

10. **Top 20 bugs / defects**  
    1. Broken widget test (`MyApp`)  
    2. Send broadcast not clickable  
    3. Dead Save/Publish/Invite/Grade/Export/Schedule buttons  
    4. Teacher nav null routes  
    5. Filters don’t filter  
    6. Pagination doesn’t paginate  
    7. Pricing not editable despite UI affordance  
    8. Payments row-click promised, missing  
    9. Search non-functional  
    10. Bell non-functional  
    11. Drag-reorder missing  
    12. Upload zones fake  
    13. No route guards  
    14. Unknown routes silently → dashboard  
    15. Platform folders missing vs README  
    16. services/ missing vs README  
    17. Notification preview brittle substring  
    18. No Semantics/a11y  
    19. Generic web manifest  
    20. Demo PII in client bundle

11. **Biggest architectural mistakes**  
    - Shipping a product-shaped admin console with **zero data plane**.  
    - Faking multi-role products via **per-screen nav presets** instead of auth.  
    - Building non-editable “inputs” that will all be rewritten.  
    - No API contract before 11 screens of fixtures.

12. **What should be built FIRST?**  
    Identity (auth + roles) + database schema + read APIs for Students/Courses — then replace controller fixtures.

13. **What should be ignored until after launch?**  
    Blog, internship module, pixel-perfect chart animations, native desktop shells, advanced growth analytics polish.

14. **If only 48 hours, exactly what would you build?**  
    Honest **hosted demo**: build web, “Mock Data” banner, disable/toast dead CTAs, fix test, anonymize fixtures, one-page architecture plan for backend. **Do not** pretend to launch.

15. **What is stopping production readiness?**  
    Absence of backend, database, auth, real workflows, and tests — i.e. the entire server-side product.

16. **Hidden technical debt?**  
    Yes: fixture-driven controllers, static input widgets, persona nav system, missing serialization, README/platform drift, broken tests.

17. **Can investors/clients safely demo?**  
    **Yes as a design walkthrough**, if verbally/visually labeled mock. **No** as a live operations demo (actions fail silently).

18. **Would you approve production deployment?**  
    **No.**

19. **What would cause users to lose trust?**  
    Fake revenue/enrollment numbers, buttons that do nothing, “sent” notifications that never arrive, payments that aren’t real, and discovering any “admin” URL works without login.

20. **Brutal conclusion**  
    This repo is a **well-executed Flutter paint of an admin console**, not a product. The README already admits controllers hold design data and services are future work. Treating this as near-production would be a governance failure. With the current codebase alone, **a full production launch in 2 days is impossible**; the only honest 48-hour outcome is a **clearly labeled UI demo** plus a backend build plan.

---

## Evidence index (high-signal citations)

- Product intent: `README.md` L1–3, L70–72  
- Dependencies (no HTTP/auth): `pubspec.yaml` L9–14  
- No auth gate: `lib/main.dart` L45–51  
- Mock dashboard data: `lib/controllers/dashboard_controller.dart` L8–69  
- Mock RBAC matrix: `lib/controllers/team_controller.dart` L7–64  
- Null teacher routes: `lib/views/widgets/nav_presets.dart` L54–63  
- Navigate skips null routes: `lib/views/layouts/admin_shell.dart` L39–40  
- Dead Send broadcast: `lib/views/screens/notifications_screen.dart` L284–304  
- Routes without guards: `lib/routes/app_router.dart` L19–33  
- Broken test: `test/widget_test.dart`  
- Web-only metadata: `.metadata` platforms → `web`  
- Git stage: 2 commits on `main` (`109e478`, `5554fa7`)
