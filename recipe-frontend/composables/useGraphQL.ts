import gql from 'graphql-tag'

// Queries
export const GET_RECIPES = gql`
  query GetRecipes($limit: Int, $offset: Int, $categoryId: uuid, $userId: uuid, $search: String) {
    recipes(
      limit: $limit
      offset: $offset
      order_by: { created_at: desc }
      where: {
        _and: [
          { category_id: { _eq: $categoryId } }
          { user_id: { _eq: $userId } }
          { _or: [{ title: { _ilike: $search } }, { description: { _ilike: $search } }] }
        ]
      }
    ) {
      id
      title
      description
      featured_image
      prep_time_minutes
      cook_time_minutes
      servings
      difficulty
      average_rating
      total_likes
      total_bookmarks
      total_ratings
      created_at
      category {
        id
        name
        slug
        icon
      }
      user {
        id
        name
        email
        avatar_url
      }
    }
  }
`

export const GET_RECIPES_SIMPLE = gql`
  query GetRecipesSimple($limit: Int, $offset: Int) {
    recipes(
      limit: $limit
      offset: $offset
      order_by: { created_at: desc }
    ) {
      id
      title
      description
      featured_image
      prep_time_minutes
      cook_time_minutes
      servings
      difficulty
      average_rating
      total_likes
      total_bookmarks
      total_ratings
      created_at
      category {
        id
        name
        slug
        icon
      }
      user {
        id
        name
        email
        avatar_url
      }
    }
  }
`

export const GET_RECIPE_BY_ID = gql`
  query GetRecipeById($id: uuid!) {
    recipes_by_pk(id: $id) {
      id
      title
      description
      featured_image
      prep_time_minutes
      cook_time_minutes
      servings
      difficulty
      average_rating
      total_likes
      total_bookmarks
      total_ratings
      created_at
      updated_at
      category {
        id
        name
        slug
        icon
      }
      user {
        id
        name
        email
        avatar_url
        bio
      }
      ingredients(order_by: { display_order: asc }) {
        id
        name
        quantity
        unit
        display_order
      }
      steps(order_by: { step_number: asc }) {
        id
        step_number
        instruction
        image_url
      }
      images(order_by: { display_order: asc }) {
        id
        image_url
        is_featured
        display_order
      }
      comments(order_by: { created_at: desc }) {
        id
        content
        created_at
        user {
          id
          name
          avatar_url
        }
      }
    }
  }
`

export const GET_CATEGORIES = gql`
  query GetCategories {
    categories(order_by: { name: asc }) {
      id
      name
      slug
      description
      icon
    }
  }
`

export const GET_RECIPES_BY_USER = gql`
  query GetRecipesByUser($userId: uuid!) {
    recipes(
      where: { user_id: { _eq: $userId } }
      order_by: { created_at: desc }
    ) {
      id
      title
      description
      featured_image
      prep_time_minutes
      average_rating
      total_likes
      created_at
      category {
        id
        name
        icon
      }
      user {
        id
        name
        email
      }
    }
  }
`

export const CHECK_LIKE = gql`
  query CheckLike($recipeId: uuid!, $userId: uuid!) {
    recipe_likes(
      where: { recipe_id: { _eq: $recipeId }, user_id: { _eq: $userId } }
    ) {
      id
    }
  }
`

export const CHECK_BOOKMARK = gql`
  query CheckBookmark($recipeId: uuid!, $userId: uuid!) {
    recipe_bookmarks(
      where: { recipe_id: { _eq: $recipeId }, user_id: { _eq: $userId } }
    ) {
      id
    }
  }
`

export const GET_USER_RATING = gql`
  query GetUserRating($recipeId: uuid!, $userId: uuid!) {
    recipe_ratings(
      where: { recipe_id: { _eq: $recipeId }, user_id: { _eq: $userId } }
    ) {
      id
      rating
    }
  }
`

// Mutations
export const CREATE_RECIPE = gql`
  mutation CreateRecipe($recipe: recipes_insert_input!) {
    insert_recipes_one(object: $recipe) {
      id
      title
    }
  }
`

export const UPDATE_RECIPE = gql`
  mutation UpdateRecipe($id: uuid!, $recipe: recipes_set_input!) {
    update_recipes_by_pk(pk_columns: { id: $id }, _set: $recipe) {
      id
      title
    }
  }
`

export const DELETE_RECIPE = gql`
  mutation DeleteRecipe($id: uuid!) {
    delete_recipes_by_pk(id: $id) {
      id
    }
  }
`

export const TOGGLE_LIKE = gql`
  mutation ToggleLike($recipeId: uuid!, $userId: uuid!) {
    insert_recipe_likes_one(
      object: { recipe_id: $recipeId, user_id: $userId }
      on_conflict: { constraint: recipe_likes_recipe_id_user_id_key, update_columns: [] }
    ) {
      id
    }
  }
`

export const REMOVE_LIKE = gql`
  mutation RemoveLike($recipeId: uuid!, $userId: uuid!) {
    delete_recipe_likes(
      where: { recipe_id: { _eq: $recipeId }, user_id: { _eq: $userId } }
    ) {
      affected_rows
    }
  }
`

export const TOGGLE_BOOKMARK = gql`
  mutation ToggleBookmark($recipeId: uuid!, $userId: uuid!) {
    insert_recipe_bookmarks_one(
      object: { recipe_id: $recipeId, user_id: $userId }
      on_conflict: { constraint: recipe_bookmarks_recipe_id_user_id_key, update_columns: [] }
    ) {
      id
    }
  }
`

export const REMOVE_BOOKMARK = gql`
  mutation RemoveBookmark($recipeId: uuid!, $userId: uuid!) {
    delete_recipe_bookmarks(
      where: { recipe_id: { _eq: $recipeId }, user_id: { _eq: $userId } }
    ) {
      affected_rows
    }
  }
`

export const ADD_COMMENT = gql`
  mutation AddComment($recipeId: uuid!, $userId: uuid!, $content: String!) {
    insert_recipe_comments_one(
      object: { recipe_id: $recipeId, user_id: $userId, content: $content }
    ) {
      id
      content
      created_at
      user {
        id
        name
        avatar_url
      }
    }
  }
`

export const ADD_RATING = gql`
  mutation AddRating($recipeId: uuid!, $userId: uuid!, $rating: Int!) {
    insert_recipe_ratings_one(
      object: { recipe_id: $recipeId, user_id: $userId, rating: $rating }
      on_conflict: { constraint: recipe_ratings_recipe_id_user_id_key, update_columns: [rating, updated_at] }
    ) {
      id
      rating
    }
  }
`

