<template>
  <div v-if="loading" class="container mx-auto px-4 py-12 text-center">
    <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"></div>
  </div>
  <div v-else-if="recipe" class="container mx-auto px-4 py-8">
    <!-- Recipe Header -->
    <div class="bg-white rounded-xl shadow-lg overflow-hidden mb-8">
      <div class="relative h-96">
        <img
          v-if="recipe.featured_image"
          :src="recipe.featured_image"
          :alt="recipe.title"
          class="w-full h-full object-cover"
        />
        <div v-else class="w-full h-full bg-gradient-to-br from-orange-200 to-red-200 flex items-center justify-center">
          <span class="text-9xl">🍳</span>
        </div>
        <div class="absolute top-4 right-4 flex space-x-2">
          <button
            v-if="isLoggedIn"
            @click="toggleLike"
            :class="[
              'px-4 py-2 rounded-full backdrop-blur-md',
              isLiked ? 'bg-red-500 text-white' : 'bg-white/90 text-gray-700 hover:bg-white'
            ]"
          >
            <span class="mr-1">{{ isLiked ? '❤️' : '🤍' }}</span>
            {{ recipe.total_likes || 0 }}
          </button>
          <button
            v-if="isLoggedIn"
            @click="toggleBookmark"
            :class="[
              'px-4 py-2 rounded-full backdrop-blur-md',
              isBookmarked ? 'bg-yellow-500 text-white' : 'bg-white/90 text-gray-700 hover:bg-white'
            ]"
          >
            <span>{{ isBookmarked ? '🔖' : '📑' }}</span>
          </button>
          <button
            v-if="canEdit"
            @click="editRecipe"
            class="px-4 py-2 rounded-full bg-white/90 text-gray-700 hover:bg-white backdrop-blur-md"
          >
            ✏️ Edit
          </button>
        </div>
      </div>

      <div class="p-8">
        <div class="flex items-start justify-between mb-4">
          <div class="flex-1">
            <h1 class="text-4xl font-bold text-gray-800 mb-2">{{ recipe.title }}</h1>
            <p class="text-lg text-gray-600 mb-4">{{ recipe.description }}</p>
            <div class="flex items-center space-x-6 text-sm text-gray-600">
              <div class="flex items-center">
                <span class="mr-2">⏱️</span>
                <span>{{ recipe.prep_time_minutes }} min prep</span>
              </div>
              <div v-if="recipe.cook_time_minutes" class="flex items-center">
                <span class="mr-2">🔥</span>
                <span>{{ recipe.cook_time_minutes }} min cook</span>
              </div>
              <div v-if="recipe.servings" class="flex items-center">
                <span class="mr-2">🍽️</span>
                <span>{{ recipe.servings }} servings</span>
              </div>
              <div class="flex items-center">
                <span class="mr-2">⭐</span>
                <span>{{ recipe.average_rating || '0.0' }} ({{ recipe.total_ratings || 0 }} ratings)</span>
              </div>
            </div>
          </div>
        </div>

        <div class="flex items-center space-x-4 mb-6">
          <div v-if="recipe.category" class="inline-block bg-orange-100 text-orange-700 px-4 py-2 rounded-lg">
            <span class="text-xl mr-2">{{ recipe.category.icon }}</span>
            {{ recipe.category.name }}
          </div>
          <div class="flex items-center text-gray-600">
            <span class="mr-2">By</span>
            <NuxtLink :to="`/users/${recipe.user.email}`" class="font-semibold text-orange-600 hover:text-orange-700">
              {{ recipe.user.name }}
            </NuxtLink>
          </div>
        </div>

        <!-- Rating Section -->
        <div v-if="isLoggedIn" class="mb-6 p-4 bg-gray-50 rounded-lg">
          <h3 class="font-semibold mb-2">Rate this recipe</h3>
          <div class="flex items-center space-x-2">
            <button
              v-for="star in 5"
              :key="star"
              @click="rateRecipe(star)"
              :class="[
                'text-2xl transition-transform hover:scale-125',
                star <= (userRating || 0) ? 'text-yellow-400' : 'text-gray-300'
              ]"
            >
              ⭐
            </button>
            <span v-if="userRating" class="ml-2 text-sm text-gray-600">
              You rated this {{ userRating }} star{{ userRating > 1 ? 's' : '' }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Main Content -->
      <div class="lg:col-span-2 space-y-8">
        <!-- Ingredients -->
        <div class="bg-white rounded-xl shadow-md p-6">
          <h2 class="text-2xl font-bold text-gray-800 mb-4">Ingredients</h2>
          <ul class="space-y-3">
            <li
              v-for="ingredient in recipe.ingredients"
              :key="ingredient.id"
              class="flex items-center p-3 bg-gray-50 rounded-lg"
            >
              <span class="text-orange-500 mr-3">✓</span>
              <span class="flex-1">
                <span v-if="ingredient.quantity">{{ ingredient.quantity }}</span>
                <span v-if="ingredient.unit" class="ml-1">{{ ingredient.unit }}</span>
                <span class="ml-2 font-medium">{{ ingredient.name }}</span>
              </span>
            </li>
          </ul>
        </div>

        <!-- Steps -->
        <div class="bg-white rounded-xl shadow-md p-6">
          <h2 class="text-2xl font-bold text-gray-800 mb-4">Instructions</h2>
          <ol class="space-y-6">
            <li
              v-for="step in recipe.steps"
              :key="step.id"
              class="flex items-start"
            >
              <span class="flex-shrink-0 w-8 h-8 bg-orange-500 text-white rounded-full flex items-center justify-center font-bold mr-4">
                {{ step.step_number }}
              </span>
              <div class="flex-1">
                <p class="text-gray-700 mb-2">{{ step.instruction }}</p>
                <img
                  v-if="step.image_url"
                  :src="step.image_url"
                  :alt="`Step ${step.step_number}`"
                  class="rounded-lg mt-2 max-w-md"
                />
              </div>
            </li>
          </ol>
        </div>

        <!-- Comments Section -->
        <div class="bg-white rounded-xl shadow-md p-6">
          <h2 class="text-2xl font-bold text-gray-800 mb-4">Comments</h2>
          
          <!-- Add Comment Form -->
          <div v-if="isLoggedIn" class="mb-6">
            <textarea
              v-model="newComment"
              placeholder="Write a comment..."
              rows="3"
              class="input-field mb-3"
            ></textarea>
            <button @click="addComment" class="btn-primary">
              Post Comment
            </button>
          </div>
          <div v-else class="mb-6 p-4 bg-gray-50 rounded-lg text-center">
            <NuxtLink to="/login" class="text-orange-600 hover:text-orange-700 font-semibold">
              Sign in to comment
            </NuxtLink>
          </div>

          <!-- Comments List -->
          <div v-if="recipe.comments && recipe.comments.length > 0" class="space-y-4">
            <div
              v-for="comment in recipe.comments"
              :key="comment.id"
              class="p-4 bg-gray-50 rounded-lg"
            >
              <div class="flex items-center mb-2">
                <div class="w-10 h-10 bg-orange-200 rounded-full flex items-center justify-center mr-3">
                  <span class="text-lg">{{ comment.user.name.charAt(0).toUpperCase() }}</span>
                </div>
                <div>
                  <p class="font-semibold text-gray-800">{{ comment.user.name }}</p>
                  <p class="text-xs text-gray-500">{{ formatDate(comment.created_at) }}</p>
                </div>
              </div>
              <p class="text-gray-700">{{ comment.content }}</p>
            </div>
          </div>
          <div v-else class="text-center py-8 text-gray-500">
            No comments yet. Be the first to comment!
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        <!-- Author Info -->
        <div class="bg-white rounded-xl shadow-md p-6">
          <h3 class="text-lg font-bold text-gray-800 mb-4">About the Author</h3>
          <div class="flex items-center mb-4">
            <div class="w-16 h-16 bg-orange-200 rounded-full flex items-center justify-center mr-4">
              <span class="text-2xl">{{ recipe.user.name.charAt(0).toUpperCase() }}</span>
            </div>
            <div>
              <NuxtLink :to="`/users/${recipe.user.email}`" class="font-semibold text-gray-800 hover:text-orange-600">
                {{ recipe.user.name }}
              </NuxtLink>
              <p class="text-sm text-gray-600">{{ recipe.user.email }}</p>
            </div>
          </div>
          <p v-if="recipe.user.bio" class="text-gray-600 text-sm">{{ recipe.user.bio }}</p>
          <NuxtLink
            :to="`/users/${recipe.user.email}`"
            class="block mt-4 text-center btn-secondary text-sm"
          >
            View All Recipes
          </NuxtLink>
        </div>

        <!-- Recipe Stats -->
        <div class="bg-white rounded-xl shadow-md p-6">
          <h3 class="text-lg font-bold text-gray-800 mb-4">Recipe Stats</h3>
          <div class="space-y-3">
            <div class="flex justify-between">
              <span class="text-gray-600">Total Likes</span>
              <span class="font-semibold">{{ recipe.total_likes || 0 }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">Bookmarks</span>
              <span class="font-semibold">{{ recipe.total_bookmarks || 0 }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">Ratings</span>
              <span class="font-semibold">{{ recipe.total_ratings || 0 }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">Created</span>
              <span class="font-semibold">{{ formatDate(recipe.created_at) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div v-else class="container mx-auto px-4 py-12 text-center">
    <span class="text-6xl block mb-4">😕</span>
    <p class="text-xl text-gray-600">Recipe not found</p>
    <NuxtLink to="/recipes" class="text-orange-600 hover:text-orange-700 mt-4 inline-block">
      Browse Recipes
    </NuxtLink>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuth } from '~/composables/useAuth'
import { useQuery, useMutation } from '@vue/apollo-composable'
import {
  GET_RECIPE_BY_ID,
  CHECK_LIKE,
  CHECK_BOOKMARK,
  GET_USER_RATING,
  TOGGLE_LIKE,
  REMOVE_LIKE,
  TOGGLE_BOOKMARK,
  REMOVE_BOOKMARK,
  ADD_COMMENT,
  ADD_RATING
} from '~/composables/useGraphQL'

const route = useRoute()
const router = useRouter()
const { isLoggedIn, user } = useAuth()

const recipe = ref(null)
const loading = ref(true)
const isLiked = ref(false)
const isBookmarked = ref(false)
const userRating = ref(0)
const newComment = ref('')

const recipeId = computed(() => route.params.id)
const canEdit = computed(() => isLoggedIn.value && recipe.value && user.value && recipe.value.user.id === user.value.id)

// Fetch recipe
const { result: recipeResult, loading: recipeLoading } = useQuery(
  GET_RECIPE_BY_ID,
  { id: recipeId.value }
)

watch(recipeResult, (data) => {
  if (data && data.recipes_by_pk) {
    recipe.value = data.recipes_by_pk
    loading.value = false
    if (isLoggedIn.value && user.value) {
      checkUserInteractions()
    }
  }
})

watch(recipeLoading, (val) => {
  loading.value = val
})

// Check if user liked/bookmarked/rated
const checkUserInteractions = async () => {
  if (!user.value || !recipeId.value) return

  // Check like
  const { result: likeResult } = useQuery(CHECK_LIKE, {
    recipeId: recipeId.value,
    userId: user.value.id
  })
  watch(likeResult, (data) => {
    isLiked.value = data && data.recipe_likes && data.recipe_likes.length > 0
  })

  // Check bookmark
  const { result: bookmarkResult } = useQuery(CHECK_BOOKMARK, {
    recipeId: recipeId.value,
    userId: user.value.id
  })
  watch(bookmarkResult, (data) => {
    isBookmarked.value = data && data.recipe_bookmarks && data.recipe_bookmarks.length > 0
  })

  // Check rating
  const { result: ratingResult } = useQuery(GET_USER_RATING, {
    recipeId: recipeId.value,
    userId: user.value.id
  })
  watch(ratingResult, (data) => {
    if (data && data.recipe_ratings && data.recipe_ratings.length > 0) {
      userRating.value = data.recipe_ratings[0].rating
    }
  })
}

// Toggle like
const { mutate: toggleLikeMutation } = useMutation(TOGGLE_LIKE)
const { mutate: removeLikeMutation } = useMutation(REMOVE_LIKE)

const toggleLike = async () => {
  if (!isLoggedIn.value || !user.value) {
    router.push('/login')
    return
  }

  try {
    if (isLiked.value) {
      await removeLikeMutation({
        recipeId: recipeId.value,
        userId: user.value.id
      })
      isLiked.value = false
      recipe.value.total_likes = Math.max(0, (recipe.value.total_likes || 0) - 1)
    } else {
      await toggleLikeMutation({
        recipeId: recipeId.value,
        userId: user.value.id
      })
      isLiked.value = true
      recipe.value.total_likes = (recipe.value.total_likes || 0) + 1
    }
  } catch (error) {
    console.error('Error toggling like:', error)
  }
}

// Toggle bookmark
const { mutate: toggleBookmarkMutation } = useMutation(TOGGLE_BOOKMARK)
const { mutate: removeBookmarkMutation } = useMutation(REMOVE_BOOKMARK)

const toggleBookmark = async () => {
  if (!isLoggedIn.value || !user.value) {
    router.push('/login')
    return
  }

  try {
    if (isBookmarked.value) {
      await removeBookmarkMutation({
        recipeId: recipeId.value,
        userId: user.value.id
      })
      isBookmarked.value = false
    } else {
      await toggleBookmarkMutation({
        recipeId: recipeId.value,
        userId: user.value.id
      })
      isBookmarked.value = true
    }
  } catch (error) {
    console.error('Error toggling bookmark:', error)
  }
}

// Rate recipe
const { mutate: addRatingMutation } = useMutation(ADD_RATING)

const rateRecipe = async (rating) => {
  if (!isLoggedIn.value || !user.value) {
    router.push('/login')
    return
  }

  try {
    await addRatingMutation({
      recipeId: recipeId.value,
      userId: user.value.id,
      rating
    })
    userRating.value = rating
  } catch (error) {
    console.error('Error rating recipe:', error)
  }
}

// Add comment
const { mutate: addCommentMutation } = useMutation(ADD_COMMENT)

const addComment = async () => {
  if (!isLoggedIn.value || !user.value || !newComment.value.trim()) {
    return
  }

  try {
    const result = await addCommentMutation({
      recipeId: recipeId.value,
      userId: user.value.id,
      content: newComment.value.trim()
    })
    
    if (result && result.data && result.data.insert_recipe_comments_one) {
      recipe.value.comments.unshift(result.data.insert_recipe_comments_one)
      newComment.value = ''
    }
  } catch (error) {
    console.error('Error adding comment:', error)
  }
}

// Edit recipe
const editRecipe = () => {
  router.push(`/recipes/${recipeId.value}/edit`)
}

// Format date
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
}

onMounted(() => {
  if (isLoggedIn.value && user.value) {
    checkUserInteractions()
  }
})
</script>

