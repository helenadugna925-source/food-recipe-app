# Setup Guide for Food Recipe App

## Quick Start

### 1. Start Database Services

```bash
cd backend
docker-compose up -d
```

Wait for services to be ready (about 10-20 seconds).

### 2. Initialize Database Schema

```bash
# Option 1: Using Docker exec
docker exec -i recipe-postgres psql -U postgres -d recipes_db < db/schema.sql

# Option 2: Using psql (if installed locally)
psql -h localhost -U postgres -d recipes_db -f db/schema.sql
# Password: postgrespassword
```

### 3. Configure Hasura

1. Open http://localhost:8080 in your browser
2. Enter admin secret: `myadminsecretkey`
3. Go to "Data" tab
4. Click "Track All" for tables
5. Click "Track All" for relationships
6. Set up permissions (see Permissions section below)

### 4. Start Backend

```bash
cd backend
go mod download
go run main.go
```

Backend runs on http://localhost:8081

### 5. Start Frontend

```bash
cd recipe-frontend
npm install
npm run dev
```

Frontend runs on http://localhost:3000

## Hasura Permissions Setup

### Recipes Table
- **Select**: Allow for all users (anonymous + authenticated)
- **Insert**: Allow for authenticated users only
- **Update**: Allow for authenticated users, with row-level check: `user_id = x-hasura-user-id`
- **Delete**: Allow for authenticated users, with row-level check: `user_id = x-hasura-user-id`

### Recipe Likes/Bookmarks/Ratings/Comments
- **Select**: Allow for all users
- **Insert**: Allow for authenticated users
- **Update**: Allow for authenticated users, with row-level check: `user_id = x-hasura-user-id`
- **Delete**: Allow for authenticated users, with row-level check: `user_id = x-hasura-user-id`

### Users Table
- **Select**: Allow for all users (public profile info)
- **Insert/Update/Delete**: Only via backend API

### Categories Table
- **Select**: Allow for all users
- **Insert/Update/Delete**: Admin only (via Hasura console)

## Troubleshooting

### Database Connection Issues
- Check if PostgreSQL is running: `docker ps`
- Check logs: `docker logs recipe-postgres`
- Verify connection: `docker exec -it recipe-postgres psql -U postgres -d recipes_db`

### Hasura Issues
- Check Hasura logs: `docker logs recipe-hasura`
- Verify JWT secret matches in Hasura console settings
- Check that all tables are tracked

### Frontend GraphQL Errors
- Open browser console to see detailed errors
- Verify Hasura endpoint is accessible: http://localhost:8080/v1/graphql
- Check that Apollo client is configured correctly in nuxt.config.ts

### Authentication Issues
- Verify JWT secret matches between backend and Hasura
- Check token expiration (default: 24 hours)
- Ensure CORS is enabled in backend

## Testing the Setup

1. **Test Database**: 
   ```bash
   docker exec -it recipe-postgres psql -U postgres -d recipes_db -c "SELECT COUNT(*) FROM categories;"
   ```
   Should return 10 (initial categories)

2. **Test Hasura**: 
   - Visit http://localhost:8080
   - Go to "GraphiQL" tab
   - Run query:
     ```graphql
     query {
       categories {
         id
         name
       }
     }
     ```

3. **Test Backend**:
   ```bash
   curl -X POST http://localhost:8081/signup \
     -H "Content-Type: application/json" \
     -d '{"name":"Test User","email":"test@example.com","password":"test123"}'
   ```

4. **Test Frontend**:
   - Visit http://localhost:3000
   - You should see the home page with categories
   - Try signing up a new account

## Next Steps

1. Create your first recipe
2. Explore categories
3. Test search and filters
4. Like and bookmark recipes
5. Add comments and ratings

## Production Deployment

For production:
1. Change JWT secret to a secure random string
2. Update CORS origins in backend
3. Use environment variables for all secrets
4. Set up proper database backups
5. Configure HTTPS
6. Use a proper image storage solution (S3, Cloudinary, etc.)

