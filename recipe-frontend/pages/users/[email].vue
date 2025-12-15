<template>
  <div class="container mx-auto px-4 py-8">
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"></div>
    </div>
    <div v-else-if="userRecipes.length > 0">
      <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-800 mb-2">Recipes by {{ userRecipes[0].user.name }}</h1>
        <p class="text-gray-600">{{ userRecipes.length }} recipe{{ userRecipes.length > 1 ? 's' : '' }}</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <RecipeCard
          v-for="recipe in userRecipes"
          :key="recipe.id"
          :recipe="recipe"
        />
      </div>
    </div>
    <div v-else class="text-center py-12">
      <span class="text-6xl block mb-4">👤</span>
      <p class="text-xl text-gray-600">No recipes found for this user</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery } from '@vue/apollo-composable'
import { GET_RECIPES_BY_USER } from '~/composables/useGraphQL'
import RecipeCard from '~/components/RecipeCard.vue'

const route = useRoute()
const email = computed(() => route.params.email)

const userRecipes = ref([])
const loading = ref(true)

// Note: This assumes we can get userId from email
// In a real app, you'd have a query to get user by email first
// For now, we'll need to modify the backend or use a different approach
// This is a simplified version

const { result: recipesResult, loading: recipesLoading } = useQuery(
  GET_RECIPES_BY_USER,
  { userId: null }, // This would need to be fetched first
  { fetchPolicy: 'network-only', skip: true }
)

watch(recipesResult, (data) => {
  if (data) {
    userRecipes.value = data.recipes || []
    loading.value = false
  }
})

watch(recipesLoading, (val) => {
  loading.value = val
})

// In a real implementation, you'd first fetch the user by email
// then use their ID to fetch recipes
// For now, this is a placeholder structure
</script>

