# eLocker Platform — Multi-tenant Smart Locker Management

A multi-tenant Ruby on Rails application for managing smart lockers across different client companies, featuring team-based role access, transactional state transitions, and an audit history log.

---

## How to Run the App

### Requirements & Setup

- **Ruby:** 3.4.0 (managed via `.ruby-version`)
- **Database:** PostgreSQL (CI uses PostgreSQL 14)
- **Bundler**

### Quick Start & Commands

```sh
bundle install
bin/rails db:setup      # creates the DB, loads the schema and the seeds
bin/rails server        # http://localhost:3000
```

## _Note on Seeding:_ Seeding replaces all companies, teams, users, lockers, assignments, and action history in one transaction. Use it to reset the demo environment.

## Demo Data & Walkthrough

The seed file creates 2 companies, 3 teams, 5 users, 3 lockers, 3 assignments, and 4 historical actions. You can switch between users via the dropdown in the header. Anna is the default user in a new session.

| User      | Access Role & Scope              |
| --------- | -------------------------------- |
| **Anna**  | Amazon · Amazon Team A · BER-01  |
| **Ben**   | Amazon · Amazon Team B · BER-02  |
| **Clara** | DPD · DPD Shared Crew · HAM-01   |
| **David** | DPD · DPD Shared Crew · HAM-01   |
| **Sam**   | Platform Support · All 3 lockers |

### Walkthrough Scenarios

1. **As Anna:** View only `BER-01`. Open and close it from its detail page.
2. **As Ben:** View only `BER-02`, initially with no history.
3. **As Clara, then David:** Both see only `HAM-01` and its history, including actions by both teammates.
4. **As Sam (Support):** Access and operate all three lockers across both companies.

---

## Data Model

| Model          | Responsibility                                                                  |
| -------------- | ------------------------------------------------------------------------------- |
| `Company`      | Owns teams and lockers.                                                         |
| `Team`         | Belongs to one company and groups local employees.                              |
| `User`         | Holds an employee or support role; determines its company context via its team. |
| `Locker`       | Belongs to one company, storing identity, location, and current state.          |
| `TeamLocker`   | Join model assigning a locker and teams within a company.                       |
| `LockerAction` | Immutable-style audit log recording state changes, actors, and timestamps.      |

### Architectural Reasoning

- **Tenant Isolation & Sharing:** Decoupling company ownership from team access via `TeamLocker` allows multiple shifts to share a physical locker.
- **Company Context:** An employee belongs to a team, which belongs to a company. This prevents conflicting multi-tenant memberships.
- **Atomic State Transitions:** `Locker#open(user)` and `Locker#close(user)` wrap row-level locking (`with_lock`), state updates, and `LockerAction` creation within a single transaction.

---

## Assumptions Questions to the Business

- Could one person be in several teams?
- Should support access be limited by time?
- Should support provide a reason for access?
- Should company admins see all of their company's lockers across teams?
- Should lockers have more states, such as offline, out of order or maintenance, or should we record failed open attempts?

---

## What Next?

- Real authentication
- Pagination and filters
- Live state updates, so everyone looking at a locker sees it open without reloading.
- Compartments and hardware integration with real command and acknowledgement: "open requested" first, then "opened" once the
  hardware confirms.

---

## How You Used AI Tools During the Task

AI tooling was leveraged during development to accelerate boilerplate configuration, draft RSpec structural scenarios, and refine layout formatting.
