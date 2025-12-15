<template>
  <footer class="bg-gray-800 text-white mt-16">
    <div class="container mx-auto px-4 py-8">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div>
          <h3 class="text-xl font-bold mb-4 flex items-center">
            <span class="text-2xl mr-2">🍳</span>
            RecipeHub
          </h3>
          <p class="text-gray-400">
            Discover and share amazing recipes from around the world.
          </p>
        </div>
        <div>
          <h4 class="font-semibold mb-4">Quick Links</h4>
          <ul class="space-y-2 text-gray-400">
            <li><NuxtLink to="/recipes" class="hover:text-white">Browse Recipes</NuxtLink></li>
            <li><NuxtLink to="/categories" class="hover:text-white">Categories</NuxtLink></li>
            <li v-if="isLoggedIn"><NuxtLink to="/recipes/create" class="hover:text-white">Create Recipe</NuxtLink></li>
          </ul>
        </div>
        <div>
          <h4 class="font-semibold mb-4">About</h4>
          <p class="text-gray-400">
            A community-driven platform for food lovers to share and discover recipes.
          </p>
        </div>
      </div>
      <div class="border-t border-gray-700 mt-8 pt-8 text-center text-gray-400">
        <p>&copy; 2025 RecipeHub. All rights reserved.</p>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { useAuth } from '~/composables/useAuth'

const { isLoggedIn } = useAuth()
</script>

