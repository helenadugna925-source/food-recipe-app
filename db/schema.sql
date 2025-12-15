-- Food Recipe App Database Schema
-- This file contains all tables, functions, triggers, and events

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipes table
CREATE TABLE IF NOT EXISTS recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    featured_image TEXT,
    prep_time_minutes INTEGER NOT NULL,
    cook_time_minutes INTEGER,
    servings INTEGER,
    difficulty VARCHAR(20) CHECK (difficulty IN ('easy', 'medium', 'hard')),
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_likes INTEGER DEFAULT 0,
    total_bookmarks INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INTEGER DEFAULT 0
);

-- Recipe images table (for multiple images)
CREATE TABLE IF NOT EXISTS recipe_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipe ingredients table
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(255) NOT NULL,
    quantity VARCHAR(100),
    unit VARCHAR(50),
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipe steps table
CREATE TABLE IF NOT EXISTS recipe_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    step_number INTEGER NOT NULL,
    instruction TEXT NOT NULL,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipe likes table
CREATE TABLE IF NOT EXISTS recipe_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(recipe_id, user_id)
);

-- Recipe bookmarks table
CREATE TABLE IF NOT EXISTS recipe_bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(recipe_id, user_id)
);

-- Recipe comments table
CREATE TABLE IF NOT EXISTS recipe_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipe ratings table
CREATE TABLE IF NOT EXISTS recipe_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(recipe_id, user_id)
);

-- ============================================
-- INDEXES for performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_recipes_user_id ON recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_category_id ON recipes(category_id);
CREATE INDEX IF NOT EXISTS idx_recipes_created_at ON recipes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_steps_recipe_id ON recipe_steps(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_images_recipe_id ON recipe_images(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_likes_recipe_id ON recipe_likes(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_likes_user_id ON recipe_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipe_bookmarks_user_id ON recipe_bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_recipe_comments_recipe_id ON recipe_comments(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ratings_recipe_id ON recipe_ratings(recipe_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Full text search index for recipes
CREATE INDEX IF NOT EXISTS idx_recipes_title_search ON recipes USING gin(to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS idx_recipes_description_search ON recipes USING gin(to_tsvector('english', description));

-- ============================================
-- POSTGRES FUNCTIONS
-- ============================================

-- Function to update recipe total_likes count
CREATE OR REPLACE FUNCTION update_recipe_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE recipes 
        SET total_likes = total_likes + 1 
        WHERE id = NEW.recipe_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE recipes 
        SET total_likes = GREATEST(0, total_likes - 1) 
        WHERE id = OLD.recipe_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to update recipe total_bookmarks count
CREATE OR REPLACE FUNCTION update_recipe_bookmarks_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE recipes 
        SET total_bookmarks = total_bookmarks + 1 
        WHERE id = NEW.recipe_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE recipes 
        SET total_bookmarks = GREATEST(0, total_bookmarks - 1) 
        WHERE id = OLD.recipe_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to update recipe average rating
CREATE OR REPLACE FUNCTION update_recipe_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL;
    total_count INTEGER;
BEGIN
    -- Calculate new average and total
    SELECT COALESCE(AVG(rating), 0), COUNT(*)
    INTO avg_rating, total_count
    FROM recipe_ratings
    WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id);
    
    -- Update recipe
    UPDATE recipes 
    SET 
        average_rating = ROUND(avg_rating::numeric, 2),
        total_ratings = total_count
    WHERE id = COALESCE(NEW.recipe_id, OLD.recipe_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to search recipes by title (full text search)
CREATE OR REPLACE FUNCTION search_recipes_by_title(search_term TEXT)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    description TEXT,
    featured_image TEXT,
    prep_time_minutes INTEGER,
    average_rating DECIMAL,
    total_likes INTEGER,
    user_id UUID,
    category_id UUID,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.title,
        r.description,
        r.featured_image,
        r.prep_time_minutes,
        r.average_rating,
        r.total_likes,
        r.user_id,
        r.category_id,
        r.created_at
    FROM recipes r
    WHERE 
        to_tsvector('english', r.title) @@ plainto_tsquery('english', search_term)
        OR r.title ILIKE '%' || search_term || '%'
    ORDER BY 
        ts_rank(to_tsvector('english', r.title), plainto_tsquery('english', search_term)) DESC,
        r.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get recipes by preparation time range
CREATE OR REPLACE FUNCTION get_recipes_by_prep_time(min_time INTEGER, max_time INTEGER)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    description TEXT,
    featured_image TEXT,
    prep_time_minutes INTEGER,
    average_rating DECIMAL,
    total_likes INTEGER,
    user_id UUID,
    category_id UUID,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.title,
        r.description,
        r.featured_image,
        r.prep_time_minutes,
        r.average_rating,
        r.total_likes,
        r.user_id,
        r.category_id,
        r.created_at
    FROM recipes r
    WHERE r.prep_time_minutes BETWEEN min_time AND max_time
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get recipes by ingredients
CREATE OR REPLACE FUNCTION get_recipes_by_ingredients(ingredient_names TEXT[])
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    description TEXT,
    featured_image TEXT,
    prep_time_minutes INTEGER,
    average_rating DECIMAL,
    total_likes INTEGER,
    user_id UUID,
    category_id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    match_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.title,
        r.description,
        r.featured_image,
        r.prep_time_minutes,
        r.average_rating,
        r.total_likes,
        r.user_id,
        r.category_id,
        r.created_at,
        COUNT(DISTINCT ri.id) as match_count
    FROM recipes r
    INNER JOIN recipe_ingredients ri ON r.id = ri.recipe_id
    WHERE LOWER(ri.name) = ANY(SELECT LOWER(unnest(ingredient_names)))
    GROUP BY r.id
    HAVING COUNT(DISTINCT ri.id) > 0
    ORDER BY match_count DESC, r.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger for updating recipe likes count
CREATE TRIGGER trigger_update_recipe_likes_count
    AFTER INSERT OR DELETE ON recipe_likes
    FOR EACH ROW
    EXECUTE FUNCTION update_recipe_likes_count();

-- Trigger for updating recipe bookmarks count
CREATE TRIGGER trigger_update_recipe_bookmarks_count
    AFTER INSERT OR DELETE ON recipe_bookmarks
    FOR EACH ROW
    EXECUTE FUNCTION update_recipe_bookmarks_count();

-- Trigger for updating recipe rating
CREATE TRIGGER trigger_update_recipe_rating
    AFTER INSERT OR UPDATE OR DELETE ON recipe_ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_recipe_rating();

-- Trigger for updating updated_at on recipes
CREATE TRIGGER trigger_update_recipes_updated_at
    BEFORE UPDATE ON recipes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for updating updated_at on users
CREATE TRIGGER trigger_update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for updating updated_at on comments
CREATE TRIGGER trigger_update_comments_updated_at
    BEFORE UPDATE ON recipe_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- INITIAL DATA (Categories)
-- ============================================

INSERT INTO categories (name, slug, description, icon) VALUES
    ('Breakfast', 'breakfast', 'Start your day right with delicious breakfast recipes', '🍳'),
    ('Lunch', 'lunch', 'Satisfying midday meals', '🥗'),
    ('Dinner', 'dinner', 'Hearty evening meals', '🍽️'),
    ('Dessert', 'dessert', 'Sweet treats and desserts', '🍰'),
    ('Appetizer', 'appetizer', 'Starters and snacks', '🥖'),
    ('Beverage', 'beverage', 'Drinks and beverages', '🥤'),
    ('Vegetarian', 'vegetarian', 'Plant-based recipes', '🥬'),
    ('Vegan', 'vegan', 'Vegan-friendly recipes', '🌱'),
    ('Gluten-Free', 'gluten-free', 'Gluten-free options', '🌾'),
    ('Quick & Easy', 'quick-easy', 'Fast and simple recipes', '⚡')
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- HASURA COMPUTED FIELDS (to be configured in Hasura Console)
-- ============================================
-- These will be configured in Hasura Console as SQL functions:
-- 1. recipes.search_by_title(search_term) -> search_recipes_by_title function
-- 2. recipes.by_prep_time(min, max) -> get_recipes_by_prep_time function
-- 3. recipes.by_ingredients(names[]) -> get_recipes_by_ingredients function

-- ============================================
-- HASURA GENERATED FIELDS (to be configured in Hasura Console)
-- ============================================
-- These will be configured in Hasura Console:
-- 1. recipes.ingredients_count -> COUNT of recipe_ingredients
-- 2. recipes.steps_count -> COUNT of recipe_steps
-- 3. recipes.images_count -> COUNT of recipe_images
-- 4. recipes.comments_count -> COUNT of recipe_comments

