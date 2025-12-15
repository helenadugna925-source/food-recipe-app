<template>
  <div class="container mx-auto px-4 py-8">
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"></div>
    </div>
    <div v-else-if="category">
      <div class="mb-8 text-center">
        <span class="text-6xl block mb-4">{{ category.icon }}</span>
        <h1 class="text-4xl font-bold text-gray-800 mb-2">{{ category.name }}</h1>
        <p class="text-lg text-gray-600">{{ category.description }}</p>
      </div>

      <div v-if="recipesLoading" class="text-center py-12">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"></div>
      </div>
      <div v-else-if="recipes.length === 0" class="text-center py-12">
        <p class="text-xl text-gray-600">No recipes in this category yet</p>
      </div>
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <RecipeCard
          v-for="recipe in recipes"
          :key="recipe.id"
          :recipe="recipe"
        />
      </div>
    </div>
    <div v-else class="text-center py-12">
      <span class="text-6xl block mb-4">😕</span>
      <p class="text-xl text-gray-600">Category not found</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery } from '@vue/apollo-composable'
import { GET_CATEGORIES, GET_RECIPES } from '~/composables/useGraphQL'
import RecipeCard from '~/components/RecipeCard.vue'

const route = useRoute()
const slug = computed(() => route.params.slug)

const category = ref(null)
const recipes = ref([])
const loading = ref(true)
const recipesLoading = ref(true)

// Fetch categories
const { result: categoriesResult, loading: categoriesLoading } = useQuery(GET_CATEGORIES)

watch(categoriesResult, (data) => {
  if (data) {
    const foundCategory = data.categories.find(cat => cat.slug === slug.value)
    if (foundCategory) {
      category.value = foundCategory
      loading.value = false
      fetchRecipes()
    } else {
      loading.value = false
    }
  }
})

watch(categoriesLoading, (val) => {
  loading.value = val
})

// Fetch recipes for this category
const { result: recipesResult, loading: recipesLoadingState, refetch } = useQuery(
  GET_RECIPES,
  { categoryId: null }, // Will be set in fetchRecipes
  { fetchPolicy: 'network-only' }
)

watch(recipesResult, (data) => {
  if (data) {
    recipes.value = data.recipes || []
    recipesLoading.value = false
  }
})

watch(recipesLoadingState, (val) => {
  recipesLoading.value = val
})

const fetchRecipes = async () => {
  if (!category.value) return
  recipesLoading.value = true
  await refetch({ categoryId: category.value.id })
}
</script>

