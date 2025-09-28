# Gudnite Draft Document

This is a draft document for the Gudnite project. It outlines the key features, goals, and implementation strategies for the project.

## User Experience Overview

will explain the user journeys.

### Feature and Components Modeling

will breakdown the user journeys into features.
will explain what components identified based on the features.

### Decisions and Assumptions

will explain the decisions made during the design process.

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

will explain the domain data models that will be used to implement the features.
will explain the database models that will be used to implement the features.
