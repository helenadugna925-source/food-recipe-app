<template>
  <NuxtLink :to="`/recipes/${recipe.id}`" class="recipe-card block">
    <div class="relative h-48 overflow-hidden">
      <img
        v-if="recipe.featured_image"
        :src="recipe.featured_image"
        :alt="recipe.title"
        class="w-full h-full object-cover"
      />
      <div v-else class="w-full h-full bg-gradient-to-br from-orange-200 to-red-200 flex items-center justify-center">
        <span class="text-6xl">🍳</span>
      </div>
      <div class="absolute top-2 right-2 flex items-center space-x-1 bg-white/90 px-2 py-1 rounded-full">
        <span class="text-yellow-500">⭐</span>
        <span class="text-sm font-semibold">{{ recipe.average_rating || '0.0' }}</span>
      </div>
    </div>
    <div class="p-4">
      <h3 class="text-lg font-semibold text-gray-800 mb-2 line-clamp-2">{{ recipe.title }}</h3>
      <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ recipe.description }}</p>
      <div class="flex items-center justify-between text-sm text-gray-500">
        <div class="flex items-center space-x-1">
          <span>⏱️</span>
          <span>{{ recipe.prep_time_minutes }} min</span>
        </div>
        <div class="flex items-center space-x-1">
          <span>❤️</span>
          <span>{{ recipe.total_likes || 0 }}</span>
        </div>
      </div>
      <div v-if="recipe.category" class="mt-2">
        <span class="inline-block bg-orange-100 text-orange-700 text-xs px-2 py-1 rounded">
          {{ recipe.category.icon }} {{ recipe.category.name }}
        </span>
      </div>
    </div>
  </NuxtLink>
</template>

<script setup>
defineProps({
  recipe: {
    type: Object,
    required: true
  }
})
</script>

