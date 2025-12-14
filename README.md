# Backend Setup

## Prerequisites
- Go 1.21 or higher
- PostgreSQL running (via Docker or locally)

## Database Setup

1. **Start PostgreSQL** (if using Docker):
   ```bash
   docker-compose up -d
   ```

2. **Initialize Database Schema**:
   ```bash
   docker exec -i recipe-postgres psql -U postgres -d recipes_db < db/schema.sql
   ```

   Or if PostgreSQL is running locally:
   ```bash
   psql -h localhost -U postgres -d recipes_db -f db/schema.sql
   ```

## Running the Backend

1. **Install Dependencies**:
   ```bash
   go mod download
   ```

2. **Set Environment Variables** (optional):
   ```bash
   export DATABASE_URL="postgres://postgres:postgrespassword@localhost:5432/recipes_db"
   export AUTH_JWT_SECRET="1234567890123456789012345678901234567890"
   ```

3. **Run the Server**:
   ```bash
   go run main.go
   ```

   The server will start on `http://localhost:8081`

## Troubleshooting

### Database Connection Error

If you get a database connection error:

1. **Check if PostgreSQL is running**:
   ```bash
   docker ps
   # Should see recipe-postgres container
   ```

2. **Check database exists**:
   ```bash
   docker exec -it recipe-postgres psql -U postgres -c "\l"
   # Should see recipes_db in the list
   ```

3. **Check connection string**:
   - Default: `postgres://postgres:postgrespassword@localhost:5432/recipes_db`
   - Make sure the password matches what's in `docker-compose.yml`

4. **Verify schema is initialized**:
   ```bash
   docker exec -it recipe-postgres psql -U postgres -d recipes_db -c "\dt"
   # Should see tables: users, recipes, categories, etc.
   ```

5. **Check PostgreSQL logs**:
   ```bash
   docker logs recipe-postgres
   ```

### Common Issues

- **"connection refused"**: PostgreSQL is not running
- **"database does not exist"**: Run the schema.sql file to create tables
- **"password authentication failed"**: Check password in connection string matches docker-compose.yml
- **"relation does not exist"**: Schema not initialized, run schema.sql

## API Endpoints

- `POST /signup` - Create new user account
- `POST /login` - Authenticate user

Both endpoints return:
```json
{
  "token": "jwt_token_here",
  "user_id": "uuid",
  "email": "user@example.com",
  "name": "User Name"
}
```

