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

will explain the apis that wil be used to implement the features.
will explain the interactions using sequence diagrams.

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
