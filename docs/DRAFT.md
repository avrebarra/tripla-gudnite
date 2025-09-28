# Gudnite Draft Document

This is a draft document for the Gudnite project. It outlines the key features, goals, and implementation strategies for the project.

## User Experience Overview

The Gudnite app provides a simple and social experience for users to track their sleep and engage with friends. The main user journeys are:

### 1. Clocking In and Out (Sleep Tracking)

- The user opens the app and records when they go to bed (clock in) and when they wake up (clock out).
- The app stores each sleep session, allowing users to view their sleep history.

### 2. Following and Unfollowing Friends

- The user can search for and follow other users to see their sleep activity.
- The user can also unfollow users at any time.

### 3. Viewing Friends’ Sleep Records

- The user can view a feed of sleep records from users they follow, limited to the previous week.
- The feed is sorted by sleep duration, showing who slept the longest.

These journeys are designed to be intuitive, focusing on quick interactions and social motivation for better sleep habits.

### Feature and Components Modeling

#### Features

1. **Sleep Tracking**

   - Users can clock in (bedtime) and clock out (wake up) to record sleep sessions.
   - View own sleep history.

2. **Social Connections**

   - Users can follow and unfollow other users.
   - View a list of followed users (friends).

3. **Friends’ Sleep Feed**
   - View sleep records from followed users for the previous week.
   - Feed is sorted by sleep duration (longest to shortest).

#### Identified Components

**Domain Data Models:**

- `User`: Represents an individual user (id, name).
- `SleepRecord`: Represents a sleep session (user_id, clock_in, clock_out, duration).
- `Follow`: Represents a follow relationship (follower_id, followed_id).

**Database Models:**

- Users table: Stores user records.
- SleepRecords table: Stores sleep sessions, linked to users.
- Followings table: Stores follow relationships between users.

**API & Backend Components:**

- SleepRecordsController: Handles clock in/out and sleep record retrieval.
- FollowsController: Handles follow/unfollow actions.
- FriendsSleepFeedController: Returns friends’ sleep records for the previous week, sorted by duration.
- Authentication: Token-based authentication for all endpoints.
- Serializers: Format API responses (e.g., ActiveModel::Serializer).
- Rswag: API documentation and OpenAPI/Swagger generation.
- Test Suite: Automated tests for all endpoints and models.

These components work together to deliver the required features, ensuring clear separation of concerns and scalability.

### Decisions and Assumptions

- will use ruby on rails framework.
- will include no frontend: it will be a backend only application exposing apis.
- will use 3-tier architecture.
- will use token based auth.
- will include an test ci pipeline.
- will use a sqlite database for simplicity: it is used for prototyping and small-scale applications. the behavior is needed in a production environment does not differ much from what sqlite can do, making it a suitable choice for the initial development phase of Gudnite.
- will use rswag for api documentation.

## Technical Specifications

### Interactions and Data Journey Breakdown

#### Planned API Endpoints

**Sleep Tracking**

- `POST /sleep_records/clock_in` — Clock in (start a new sleep session)
- `POST /sleep_records/clock_out` — Clock out (end the current sleep session, precalculate duration)
- `GET /sleep_records` — List all sleep records for the authenticated user

**Social Connections**

- `POST /followings` — Follow another user
- `DELETE /followings/:id` — Unfollow a user
- `GET /followings` — List users the authenticated user is following

**Friends’ Sleep Feed**

- `GET /friends/sleep_feed` — Get previous week’s sleep records from followed users, sorted by duration

**Authentication**

- Token-based authentication required for all endpoints

Each endpoint is designed to be RESTful, stateless, and returns JSON responses. Endpoints are versioned and documented using Swagger (rswag).

#### Unified Sequence Diagram for All Main Flows

```
participant api-controller
participant auth-service
participant clockin-service
participant follow-service
participant friends-service
participant user-model
participant sleeprecord-model
participant follow-model

entryspacing 0.5

group 0. User Auth (Login/Logout)
api-controller->auth-service: login\nPOST /login\n--data:email,password--
activate auth-service
auth-service->user-model: find_by(email)
activate user-model
user-model-->>auth-service: user | nil
deactivate user-model
auth-service->auth-service: user.authenticate(password)?
alt success
   auth-service->user-model: update(token: SecureRandom.hex)
   activate user-model
   user-model-->>auth-service: user_with_token
   deactivate user-model
   auth-service-->>api-controller: JSON {token}
else failure
   auth-service-->>api-controller: JSON {error:Invalid login}, 401
end
deactivate auth-service
end

api-controller->auth-service: logout\nDELETE /logout\n--header:Authorization:Bearer token--
activate auth-service
auth-service->user-model: find_by(token)
activate user-model
user-model-->>auth-service: user
deactivate user-model
auth-service->user-model: update(token:nil)
activate user-model
user-model-->>auth-service: user
deactivate user-model
auth-service-->>api-controller: 204 No Content
deactivate auth-service
end

group 1a. Start Sleep Session (Clock In)
api-controller->clockin-service: start session\nPOST /sleep_sessions/start\n--data:sleep_time--
activate clockin-service
clockin-service->sleeprecord-model: create(user_id, sleep_time)
activate sleeprecord-model
sleeprecord-model-->>clockin-service: sleep_session
deactivate sleeprecord-model
clockin-service-->>api-controller: JSON {sleep_session}
deactivate clockin-service
end

group 1b. End Sleep Session (Clock Out)
api-controller->clockin-service: end session\nPOST /sleep_sessions/:id/end\n--data:wake_time--
activate clockin-service
clockin-service->sleeprecord-model: update(session_id, wake_time)
activate sleeprecord-model
sleeprecord-model-->>clockin-service: updated_sleep_session
deactivate sleeprecord-model
clockin-service-->>api-controller: JSON {updated_sleep_session}
deactivate clockin-service
end

group 2a. Follow User
api-controller->follow-service: follow user\nPOST /follows\n--data:follower_id,followed_id--
activate follow-service
follow-service->follow-model: create(follower_id,followed_id)
activate follow-model
follow-model-->>follow-service: follow_record
deactivate follow-model
follow-service-->>api-controller: JSON {status:ok}
deactivate follow-service
end

group 2b. Unfollow User
api-controller->follow-service: unfollow user\nDELETE /follows/:id
activate follow-service
follow-service->follow-model: destroy(id)
activate follow-model
follow-model-->>follow-service: deleted
deactivate follow-model
follow-service-->>api-controller: JSON {status:ok}
deactivate follow-service
end

group 3. Friends’ Sleep Records (JOIN query)
api-controller->friends-service: get friends sleep records\nGET /friends/sleep_records
activate friends-service

friends-service->sleeprecord-model: find_all_by_following(user_id)\nJOIN follows f ON f.followed_id = sleep_records.user_id\nWHERE f.follower_id = user_id\nAND created_at IN last_week\nORDER BY (wake_time-sleep_time) DESC
activate sleeprecord-model
note right of sleeprecord-model: Single query with JOIN\nEfficient even with thousands of follows
sleeprecord-model-->>friends-service: [friends_sleep_records]
deactivate sleeprecord-model

friends-service-->>api-controller: JSON [friends_sleep_records]
deactivate friends-service
end

```

---

**Query Plan Note:**

The friends’ sleep records API uses a single JOIN query for efficiency:

```sql
SELECT sr.*
FROM sleep_records sr
JOIN follows f ON f.followed_id = sr.user_id
WHERE f.follower_id = :current_user_id
   AND sr.created_at BETWEEN :last_week_start AND :last_week_end
ORDER BY (sr.wake_time - sr.sleep_time) DESC;
```

In Rails ActiveRecord:

```ruby
SleepRecord.joins("JOIN follows f ON f.followed_id = sleep_records.user_id")
                .where(f: { follower_id: current_user.id })
                .where(created_at: 1.week.ago..Time.current)
                .order(Arel.sql("wake_time - sleep_time DESC"))
```

### Data Models

#### User

| Field      | Type     | Notes            |
| ---------- | -------- | ---------------- |
| id         | integer  | Primary key      |
| name       | string   | Unique, not null |
| created_at | datetime |                  |
| updated_at | datetime |                  |

**Relations:**

- Has many `sleep_records`
- Has many `followings` (users this user follows)
- Has many `followers` (users following this user)

---

#### SleepRecord

| Field      | Type     | Notes                 |
| ---------- | -------- | --------------------- |
| id         | integer  | Primary key           |
| user_id    | integer  | Foreign key to users  |
| clock_in   | datetime | When user went to bed |
| clock_out  | datetime | When user woke up     |
| duration   | integer  | Duration in seconds   |
| created_at | datetime |                       |
| updated_at | datetime |                       |

**Relations:**

- Belongs to `user`

**Behavioral Notes:**

- `duration` is calculated as `clock_out - clock_in` (in seconds) and is precalculated and stored at the moment of clock out.
- Only one open (no clock_out) record per user at a time.

---

#### Following

| Field       | Type     | Notes                               |
| ----------- | -------- | ----------------------------------- |
| id          | integer  | Primary key                         |
| follower_id | integer  | Foreign key to users (the follower) |
| followed_id | integer  | Foreign key to users (the followed) |
| created_at  | datetime |                                     |
| updated_at  | datetime |                                     |

**Relations:**

- `follower_id` references the user who follows
- `followed_id` references the user being followed

**Behavioral Notes:**

- Unique constraint on (follower_id, followed_id) to prevent duplicates
- No self-following allowed

---

**General Notes:**

- All models include timestamps for auditing.
- Associations are set up for easy querying (e.g., user.followings, user.sleep_records).
