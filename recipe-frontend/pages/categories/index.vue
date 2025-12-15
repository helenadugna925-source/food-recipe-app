<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-4xl font-bold text-gray-800 mb-8 text-center">All Categories</h1>
    
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"></div>
    </div>
    <div v-else class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
      <NuxtLink
        v-for="category in categories"
        :key="category.id"
        :to="`/categories/${category.slug}`"
        class="card p-6 text-center hover:shadow-2xl transform hover:scale-105 transition-all"
      >
        <div class="text-5xl mb-4">{{ category.icon }}</div>
        <h3 class="text-lg font-semibold text-gray-800">{{ category.name }}</h3>
        <p class="text-sm text-gray-600 mt-2">{{ category.description }}</p>
      </NuxtLink>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_CATEGORIES } from '~/composables/useGraphQL'

const categories = ref([])
const loading = ref(true)

const { result: categoriesResult, loading: categoriesLoading } = useQuery(GET_CATEGORIES)

watch(categoriesResult, (data) => {
  if (data) {
    categories.value = data.categories
    loading.value = false
  }
})

watch(categoriesLoading, (val) => {
  loading.value = val
})
</script>

