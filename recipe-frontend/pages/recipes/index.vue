<template>
  <div class="container mx-auto px-4 py-8">
    <div class="mb-8">
      <h1 class="text-4xl font-bold text-gray-800 mb-4">Browse Recipes</h1>
      <p class="text-gray-600">Discover amazing recipes from our community</p>
    </div>

    <!-- Filters Section -->
    <div class="bg-white rounded-xl shadow-md p-6 mb-8">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <!-- Search -->
        <div>
          <label class="block text-sm font-semibold text-gray-700 mb-2">Search</label>
          <input
            v-model="filters.search"
            type="text"
            placeholder="Search recipes..."
            class="input-field"
            @input="debouncedSearch"
          />
        </div>

        <!-- Category Filter -->
        <div>
          <label class="block text-sm font-semibold text-gray-700 mb-2">Category</label>
          <select v-model="filters.categoryId" class="input-field" @change="applyFilters">
            <option value="">All Categories</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">
              {{ cat.icon }} {{ cat.name }}
            </option>
          </select>
        </div>

        <!-- Prep Time Filter -->
        <div>
          <label class="block text-sm font-semibold text-gray-700 mb-2">Prep Time (min)</label>
          <select v-model="filters.prepTime" class="input-field" @change="applyFilters">
            <option value="">Any Time</option>
            <option value="0-15">0-15 minutes</option>
            <option value="15-30">15-30 minutes</option>
            <option value="30-60">30-60 minutes</option>
            <option value="60+">60+ minutes</option>
          </select>
        </div>

        <!-- Ingredients Filter -->
        <div>
          <label class="block text-sm font-semibold text-gray-700 mb-2">Ingredients</label>
          <input
            v-model="filters.ingredients"
            type="text"
            placeholder="e.g., chicken, tomato"
            class="input-field"
            @input="debouncedSearch"
          />
        </div>
      </div>

      <div class="mt-4 flex justify-end">
        <button @click="clearFilters" class="text-gray-600 hover:text-gray-800 text-sm font-medium">
          Clear Filters
        </button>
      </div>
    </div>

    <!-- Recipes Grid -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"></div>
    </div>
    <div v-else-if="recipes.length === 0" class="text-center py-12">
      <span class="text-6xl block mb-4">🔍</span>
      <p class="text-xl text-gray-600">No recipes found</p>
      <p class="text-gray-500 mt-2">Try adjusting your filters</p>
    </div>
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <RecipeCard
        v-for="recipe in recipes"
        :key="recipe.id"
        :recipe="recipe"
      />
    </div>

    <!-- Load More Button -->
    <div v-if="hasMore && !loading" class="text-center mt-8">
      <button @click="loadMore" class="btn-secondary">
        Load More Recipes
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery } from '@vue/apollo-composable'
import { GET_RECIPES, GET_RECIPES_SIMPLE, GET_CATEGORIES } from '~/composables/useGraphQL'
import RecipeCard from '~/components/RecipeCard.vue'

const route = useRoute()
const recipes = ref([])
const categories = ref([])
const loading = ref(true)
const hasMore = ref(true)
const limit = 12
const offset = ref(0)

const filters = reactive({
  search: route.query.search || '',
  categoryId: route.query.category || '',
  prepTime: route.query.prepTime || '',
  ingredients: route.query.ingredients || ''
})

let searchTimeout = null

const debouncedSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    applyFilters()
  }, 500)
}

const applyFilters = () => {
  offset.value = 0
  recipes.value = []
  fetchRecipes()
}

const clearFilters = () => {
  filters.search = ''
  filters.categoryId = ''
  filters.prepTime = ''
  filters.ingredients = ''
  applyFilters()
}

const loadMore = () => {
  offset.value += limit
  fetchRecipes()
}

// Fetch categories
const { result: categoriesResult } = useQuery(GET_CATEGORIES)
watch(categoriesResult, (data) => {
  if (data) {
    categories.value = data.categories
  }
})

// Build query variables
const getQueryVariables = () => {
  const vars = {
    limit,
    offset: offset.value,
    categoryId: filters.categoryId || null,
    userId: null,
    search: filters.search ? `%${filters.search}%` : null
  }
  return vars
}

// Fetch recipes - use simple query if no filters
const shouldUseSimpleQuery = computed(() => {
  return !filters.categoryId && !filters.search && !filters.prepTime && !filters.ingredients
})

const { result: recipesResult, loading: recipesLoading, refetch } = useQuery(
  shouldUseSimpleQuery.value ? GET_RECIPES_SIMPLE : GET_RECIPES,
  getQueryVariables(),
  { fetchPolicy: 'network-only' }
)

watch(recipesResult, (data) => {
  if (data) {
    const newRecipes = data.recipes || []
    if (offset.value === 0) {
      recipes.value = newRecipes
    } else {
      recipes.value = [...recipes.value, ...newRecipes]
    }
    hasMore.value = newRecipes.length === limit
    loading.value = false
  }
})

watch(recipesLoading, (val) => {
  loading.value = val
})

const fetchRecipes = async () => {
  loading.value = true
  await refetch(getQueryVariables())
}

onMounted(() => {
  fetchRecipes()
})
</script>
