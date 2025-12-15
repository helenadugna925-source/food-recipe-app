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

