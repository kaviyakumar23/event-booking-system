# Event Booking System

A Ruby on Rails API-based event booking system that allows event organizers to create and manage events, and customers to book tickets.

## System Requirements

- Ruby version: 2.7.6
- Rails version: 7.1.0
- PostgreSQL database
- Redis (for Sidekiq background jobs)

## Key Features

- JWT-based authentication
- Role-based authorization (Event Organizers and Customers)
- Event management
- Ticket booking system
- Background job processing with Sidekiq

## Setup

1. Clone the repository

```bash
git clone <repository-url>
cd event-booking
```

2. Install dependencies

```bash
bundle install
```

3. Configure environment variables
   - Configure your database credentials in `config/database.yml`
   - Set up the database:

```bash
rails db:create
rails db:migrate
```

4. Add JWT secret key to Rails credentials

```bash
EDITOR="vim" rails credentials:edit
# Add the following line:
jwt_secret_key: your_secret_key_here
```

5. Update required Environment variables

```bash
cp .env.example .env
```

6. Start the server

```bash
rails server
```

## Start Sidekiq (in a separate terminal)

```bash
bundle exec sidekiq
```

## API Endpoints

### Authentication

- `POST /register` - Register a new user (customer or event organizer)
- `POST /signin` - Sign in and receive JWT token

### Events (Event Organizer only)

- `GET /events` - List all events
- `POST /events` - Create a new event
- `GET /events/:id` - Get event details
- `PATCH /events/:id` - Update event
- `DELETE /events/:id` - Delete event

### Bookings (Customer only)

- `POST /bookings` - Create a new booking
- `GET /bookings` - List user's bookings
- `GET /bookings/:id` - Get booking details
- `PATCH /bookings/:id` - Update booking (only cancellation if pending)

### Tickets (Event Organizer only)

- `GET /tickets` - List available tickets
- `GET /tickets/:id` - Get ticket details
- `POST /tickets` - Create ticket types (event organizer only)
- `PATCH /tickets/:id` - Update ticket details (event organizer only)
- `DELETE /tickets/:id` - Delete ticket (event organizer only if no bookings)
