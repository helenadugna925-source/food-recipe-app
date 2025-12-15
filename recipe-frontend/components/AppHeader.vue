<template>
  <header class="bg-white shadow-md sticky top-0 z-50">
    <nav class="container mx-auto px-4 py-4">
      <div class="flex items-center justify-between">
        <NuxtLink to="/" class="flex items-center space-x-2">
          <span class="text-3xl">🍳</span>
          <span class="text-2xl font-bold text-orange-600">RecipeHub</span>
        </NuxtLink>

        <div class="flex items-center space-x-6">
          <NuxtLink
            to="/recipes"
            class="text-gray-700 hover:text-orange-600 font-medium transition-colors"
          >
            Browse Recipes
          </NuxtLink>

          <NuxtLink
            to="/categories"
            class="text-gray-700 hover:text-orange-600 font-medium transition-colors"
          >
            Categories
          </NuxtLink>

          <template v-if="isLoggedIn">
            <NuxtLink
              to="/recipes/create"
              class="btn-primary text-sm"
            >
              + Create Recipe
            </NuxtLink>
            <NuxtLink
              :to="`/users/${user?.email}`"
              class="text-gray-700 hover:text-orange-600 font-medium transition-colors"
            >
              My Recipes
            </NuxtLink>
            <button
              @click="handleLogout"
              class="text-gray-700 hover:text-orange-600 font-medium transition-colors"
            >
              Logout
            </button>
          </template>

          <template v-else>
            <NuxtLink
              to="/login"
              class="text-gray-700 hover:text-orange-600 font-medium transition-colors"
            >
              Login
            </NuxtLink>
            <NuxtLink
              to="/signup"
              class="btn-primary text-sm"
            >
              Sign Up
            </NuxtLink>
          </template>
        </div>
      </div>
    </nav>
  </header>
</template>

<script setup>
import { useAuth } from '~/composables/useAuth'
import { useRouter } from 'vue-router'

const { isLoggedIn, user, clearAuth } = useAuth()
const router = useRouter()

const handleLogout = () => {
  clearAuth()
  router.push('/')
}
</script>

