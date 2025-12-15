# Food Recipe App

A beautiful, full-featured food recipe website built with Nuxt 3, Vue 3, Hasura, and PostgreSQL. Users can browse, create, share, and interact with recipes.

## Features

### Public Features
- Browse all recipes shared by the community
- Browse recipes by categories
- Browse recipes by creator
- Filter recipes by preparation time
- Filter recipes by ingredients
- Search recipes by title
- View recipe details with ingredients, steps, and comments

### User Features (Requires Account)
- Sign up and create an account
- Create, edit, and delete your own recipes
- Upload multiple images per recipe (with featured image selection)
- Add dynamic ingredients and preparation steps
- Set preparation time, category, title, and description
- Like recipes from other users
- Bookmark recipes
- Comment on recipes
- Rate recipes (1-5 stars)

## Tech Stack

### Frontend
- **Nuxt 3** - Vue.js framework
- **Vue 3** - Progressive JavaScript framework
- **Vite** - Build tool
- **Vue Apollo** - GraphQL client
- **Vee-Validate** - Form validation
- **Tailwind CSS** - Utility-first CSS framework
- **Yup** - Schema validation

### Backend
- **Hasura** - GraphQL engine (Docker)
- **PostgreSQL** - Database (Docker)
- **Go** - Authentication service
- **JWT** - Authentication tokens

### Database Features
- PostgreSQL functions for search and filtering
- Database triggers for automatic count updates
- Hasura events for real-time updates
- Hasura computed fields
- Hasura generated fields

## Project Structure

```
food-recipe-app/
├── backend/
│   ├── db/
│   │   └── schema.sql          # Database schema with tables, functions, triggers
│   ├── handlers/
│   │   └── auth.go             # Authentication handlers
│   ├── utils/
│   │   ├── hash.go             # Password hashing utilities
│   │   └── jwt.go              # JWT token generation
│   ├── docker-compose.yml      # Docker setup for Hasura and PostgreSQL
│   └── main.go                 # Go server entry point
├── recipe-frontend/
│   ├── assets/
│   │   └── css/
│   │       └── main.css        # Tailwind CSS and custom styles
│   ├── components/
│   │   ├── AppHeader.vue       # Navigation header
│   │   ├── AppFooter.vue       # Footer
│   │   └── RecipeCard.vue      # Recipe card component
│   ├── composables/
│   │   ├── useAuth.js          # Authentication composable
│   │   └── useGraphQL.ts       # GraphQL queries and mutations
│   ├── layouts/
│   │   └── default.vue         # Default layout
│   ├── pages/
│   │   ├── index.vue           # Home page
│   │   ├── login.vue           # Login page
│   │   ├── signup.vue          # Signup page
│   │   ├── recipes/
│   │   │   ├── index.vue       # Recipe listing with filters
│   │   │   ├── create.vue      # Create recipe page
│   │   │   ├── [id].vue        # Recipe detail page
│   │   │   └── [id]/
│   │   │       └── edit.vue    # Edit recipe page
│   │   ├── categories/
│   │   │   ├── index.vue       # All categories
│   │   │   └── [slug].vue      # Category detail page
│   │   └── users/
│   │       └── [email].vue      # User profile page
│   ├── nuxt.config.ts          # Nuxt configuration
│   └── package.json            # Frontend dependencies
└── README.md                   # This file
```

## Setup Instructions

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ and npm
- Go 1.21+ (for backend)

### 1. Database Setup

Start PostgreSQL and Hasura using Docker:

```bash
cd backend
docker-compose up -d
```

This will start:
- PostgreSQL on port 5432
- Hasura Console on http://localhost:8080

### 2. Initialize Database Schema

Connect to PostgreSQL and run the schema:

```bash
# Using psql (if installed)
psql -h localhost -U postgres -d recipes_db -f db/schema.sql
# Password: postgrespassword

# Or using Docker
docker exec -i recipe-postgres psql -U postgres -d recipes_db < db/schema.sql
```

### 3. Configure Hasura

1. Open Hasura Console: http://localhost:8080
2. Enter admin secret: `myadminsecretkey`
3. Track all tables:
   - Go to "Data" tab
   - Click "Track All" for tables
   - Click "Track All" for relationships
4. Set up permissions:
   - For `recipes` table: Allow select for all users, insert/update/delete for authenticated users (with user_id check)
   - For `recipe_likes`, `recipe_bookmarks`, `recipe_ratings`, `recipe_comments`: Allow select for all, insert/update/delete for authenticated users
   - For `users` table: Allow select for all users
5. Configure computed fields (optional):
   - In Hasura Console, go to "Modify" tab for `recipes` table
   - Add computed fields using the PostgreSQL functions defined in schema.sql

### 4. Backend Setup

```bash
cd backend
go mod download
go run main.go
```

The backend will run on http://localhost:8081

### 5. Frontend Setup

```bash
cd recipe-frontend
npm install
npm run dev
```

The frontend will run on http://localhost:3000

## Environment Variables

### Backend
Create a `.env` file in the `backend` directory:

```env
AUTH_JWT_SECRET=1234567890123456789012345678901234567890
ACCESS_TOKEN_EXP_MIN=1440
REFRESH_TOKEN_EXP_DAYS=30
DATABASE_URL=postgres://postgres:postgrespassword@localhost:5432/recipes_db
```

### Frontend
The frontend uses runtime config defined in `nuxt.config.ts`. Update if needed:

```typescript
runtimeConfig: {
  public: {
    apiBase: 'http://localhost:8081',
    hasuraEndpoint: 'http://localhost:8080/v1/graphql',
    hasuraAdminSecret: 'myadminsecretkey'
  }
}
```

## Database Schema Highlights

### Tables
- `users` - User accounts
- `categories` - Recipe categories
- `recipes` - Main recipe table
- `recipe_images` - Multiple images per recipe
- `recipe_ingredients` - Dynamic ingredients
- `recipe_steps` - Preparation steps
- `recipe_likes` - User likes
- `recipe_bookmarks` - User bookmarks
- `recipe_comments` - Recipe comments
- `recipe_ratings` - Recipe ratings

### PostgreSQL Functions
- `update_recipe_likes_count()` - Auto-update like counts
- `update_recipe_bookmarks_count()` - Auto-update bookmark counts
- `update_recipe_rating()` - Auto-calculate average ratings
- `search_recipes_by_title()` - Full-text search
- `get_recipes_by_prep_time()` - Filter by preparation time
- `get_recipes_by_ingredients()` - Filter by ingredients

### Triggers
- Auto-update `total_likes` when likes are added/removed
- Auto-update `total_bookmarks` when bookmarks are added/removed
- Auto-update `average_rating` when ratings change
- Auto-update `updated_at` timestamps

## Usage

1. **Browse Recipes**: Visit the home page to see featured recipes and categories
2. **Search**: Use the search bar and filters on the recipes page
3. **Sign Up**: Create an account to start sharing recipes
4. **Create Recipe**: Click "Create Recipe" to add your own recipe
5. **Interact**: Like, bookmark, comment, and rate recipes
6. **Manage**: Edit or delete your own recipes

## API Endpoints

### Authentication (Go Backend)
- `POST /signup` - Create new account
- `POST /login` - Sign in
- `POST /refresh` - Refresh access token

### GraphQL (Hasura)
All recipe operations use Hasura GraphQL API at `http://localhost:8080/v1/graphql`

## Development

### Running in Development Mode

```bash
# Terminal 1: Database
cd backend && docker-compose up

# Terminal 2: Backend
cd backend && go run main.go

# Terminal 3: Frontend
cd recipe-frontend && npm run dev
```

### Building for Production

```bash
# Frontend
cd recipe-frontend
npm run build

# Backend
cd backend
go build -o recipe-server main.go
```

## Troubleshooting

### Hasura Connection Issues
- Ensure PostgreSQL is running: `docker ps`
- Check Hasura logs: `docker logs recipe-hasura`
- Verify database URL in Hasura Console

### GraphQL Errors
- Check Hasura Console for query errors
- Verify table permissions are set correctly
- Ensure relationships are tracked

### Authentication Issues
- Verify JWT secret matches between backend and Hasura
- Check token expiration settings
- Ensure CORS is configured correctly

## License

This project is open source and available for educational purposes.

## Contributing

Feel free to submit issues and enhancement requests!

