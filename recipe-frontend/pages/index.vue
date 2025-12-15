<template>
  <div>
    <!-- Hero Section -->
    <section
      class="bg-gradient-to-r from-orange-500 to-red-500 text-white py-20"
    >
      <div class="container mx-auto px-4 text-center">
        <h1 class="text-5xl font-bold mb-4">Discover Amazing Recipes</h1>
        <p class="text-xl mb-8 text-orange-100">
          Share your culinary creations and explore recipes from food lovers
          worldwide
        </p>
        <div class="flex justify-center space-x-4">
          <NuxtLink
            to="/recipes"
            class="btn-secondary bg-white text-orange-600 hover:bg-orange-50"
          >
            Browse Recipes
          </NuxtLink>
          <NuxtLink
            v-if="!isLoggedIn"
            to="/signup"
            class="btn-secondary bg-orange-600 text-white hover:bg-orange-700 border-0"
          >
            Get Started
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Categories Section -->
    <section class="py-16 bg-white">
      <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-center mb-12 text-gray-800">
          Browse by Category
        </h2>
        <div v-if="loading" class="text-center py-12">
          <div
            class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"
          ></div>
        </div>
        <div
          v-else
          class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6"
        >
          <NuxtLink
            v-for="category in categories"
            :key="category.id"
            :to="`/categories/${category.slug}`"
            class="card p-6 text-center hover:shadow-2xl transform hover:scale-105 transition-all"
          >
            <div class="text-5xl mb-4">{{ category.icon }}</div>
            <h3 class="text-lg font-semibold text-gray-800">
              {{ category.name }}
            </h3>
            <p class="text-sm text-gray-600 mt-2">{{ category.description }}</p>
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Featured Recipes Section -->
    <section class="py-16 bg-gray-50">
      <div class="container mx-auto px-4">
        <div class="flex justify-between items-center mb-8">
          <h2 class="text-3xl font-bold text-gray-800">Featured Recipes</h2>
          <NuxtLink
            to="/recipes"
            class="text-orange-600 hover:text-orange-700 font-medium"
          >
            View All →
          </NuxtLink>
        </div>
        <div v-if="recipesLoading" class="text-center py-12">
          <div
            class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"
          ></div>
        </div>
        <div
          v-else
          class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6"
        >
          <RecipeCard
            v-for="recipe in featuredRecipes"
            :key="recipe.id"
            :recipe="recipe"
          />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useAuth } from "~/composables/useAuth";
import { useQuery } from "@vue/apollo-composable";
import { GET_CATEGORIES, GET_RECIPES_SIMPLE } from "~/composables/useGraphQL";
import RecipeCard from "~/components/RecipeCard.vue";

const { isLoggedIn } = useAuth();

const categories = ref([]);
const featuredRecipes = ref([]);
const loading = ref(true);
const recipesLoading = ref(true);

// Fetch categories
const { result: categoriesResult, loading: categoriesLoading } =
  useQuery(GET_CATEGORIES);

watch(categoriesResult, (data) => {
  if (data) {
    categories.value = data.categories;
    loading.value = false;
  }
});

watch(categoriesLoading, (val) => {
  loading.value = val;
});

// Fetch featured recipes - use simple query without filters
const { result: recipesResult, loading: recipesLoadingState } = useQuery(
  GET_RECIPES_SIMPLE,
  {
    limit: 8,
    offset: 0,
  }
);

watch(recipesResult, (data) => {
  if (data) {
    featuredRecipes.value = data.recipes;
    recipesLoading.value = false;
  }
});

watch(recipesLoadingState, (val) => {
  recipesLoading.value = val;
});
</script>
