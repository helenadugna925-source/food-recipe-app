<template>
  <div v-if="loading" class="container mx-auto px-4 py-12 text-center">
    <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500"></div>
  </div>
  <div v-else-if="recipe" class="container mx-auto px-4 py-8 max-w-4xl">
    <h1 class="text-4xl font-bold text-gray-800 mb-8">Edit Recipe</h1>

    <form @submit.prevent="handleSubmit(onSubmit)" class="space-y-8">
      <!-- Same form structure as create.vue but pre-filled -->
      <!-- Basic Information -->
      <div class="bg-white rounded-xl shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Basic Information</h2>
        
        <div class="mb-5">
          <label class="block text-sm font-semibold text-gray-700 mb-2">Recipe Title *</label>
          <input
            v-model="form.title"
            type="text"
            class="input-field"
          />
          <p v-if="errors.title" class="text-red-500 text-sm mt-1">{{ errors.title }}</p>
        </div>

        <div class="mb-5">
          <label class="block text-sm font-semibold text-gray-700 mb-2">Description *</label>
          <textarea
            v-model="form.description"
            rows="4"
            class="input-field"
          ></textarea>
          <p v-if="errors.description" class="text-red-500 text-sm mt-1">{{ errors.description }}</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-5">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Prep Time (minutes) *</label>
            <input
              v-model.number="form.prep_time_minutes"
              type="number"
              min="1"
              class="input-field"
            />
            <p v-if="errors.prep_time_minutes" class="text-red-500 text-sm mt-1">{{ errors.prep_time_minutes }}</p>
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Cook Time (minutes)</label>
            <input
              v-model.number="form.cook_time_minutes"
              type="number"
              min="0"
              class="input-field"
            />
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Servings</label>
            <input
              v-model.number="form.servings"
              type="number"
              min="1"
              class="input-field"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Category *</label>
            <select v-model="form.category_id" class="input-field">
              <option value="">Select a category</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                {{ cat.icon }} {{ cat.name }}
              </option>
            </select>
            <p v-if="errors.category_id" class="text-red-500 text-sm mt-1">{{ errors.category_id }}</p>
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Difficulty</label>
            <select v-model="form.difficulty" class="input-field">
              <option value="">Select difficulty</option>
              <option value="easy">Easy</option>
              <option value="medium">Medium</option>
              <option value="hard">Hard</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Images -->
      <div class="bg-white rounded-xl shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Images</h2>
        
        <div class="mb-4">
          <label class="block text-sm font-semibold text-gray-700 mb-2">Featured Image URL *</label>
          <input
            v-model="form.featured_image"
            type="url"
            class="input-field"
          />
          <p v-if="errors.featured_image" class="text-red-500 text-sm mt-1">{{ errors.featured_image }}</p>
        </div>

        <div v-if="form.featured_image" class="mb-6">
          <img :src="form.featured_image" alt="Featured" class="w-full h-64 object-cover rounded-lg" />
        </div>
      </div>

      <!-- Ingredients -->
      <div class="bg-white rounded-xl shadow-md p-6">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold text-gray-800">Ingredients *</h2>
          <button type="button" @click="addIngredient" class="btn-secondary text-sm">
            + Add Ingredient
          </button>
        </div>
        <p v-if="errors.ingredients" class="text-red-500 text-sm mb-4">{{ errors.ingredients }}</p>
        
        <div class="space-y-4">
          <div
            v-for="(ingredient, index) in form.ingredients"
            :key="index"
            class="flex gap-4 items-start p-4 bg-gray-50 rounded-lg"
          >
            <div class="flex-1 grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Name *</label>
                <input
                  v-model="ingredient.name"
                  type="text"
                  class="input-field text-sm"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Quantity</label>
                <input
                  v-model="ingredient.quantity"
                  type="text"
                  class="input-field text-sm"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Unit</label>
                <input
                  v-model="ingredient.unit"
                  type="text"
                  class="input-field text-sm"
                />
              </div>
            </div>
            <button
              type="button"
              @click="removeIngredient(index)"
              class="px-3 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 text-sm"
            >
              Remove
            </button>
          </div>
        </div>
      </div>

      <!-- Steps -->
      <div class="bg-white rounded-xl shadow-md p-6">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold text-gray-800">Instructions *</h2>
          <button type="button" @click="addStep" class="btn-secondary text-sm">
            + Add Step
          </button>
        </div>
        <p v-if="errors.steps" class="text-red-500 text-sm mb-4">{{ errors.steps }}</p>
        
        <div class="space-y-4">
          <div
            v-for="(step, index) in form.steps"
            :key="index"
            class="p-4 bg-gray-50 rounded-lg"
          >
            <div class="flex items-center mb-3">
              <span class="w-8 h-8 bg-orange-500 text-white rounded-full flex items-center justify-center font-bold mr-3">
                {{ index + 1 }}
              </span>
              <button
                type="button"
                @click="removeStep(index)"
                class="ml-auto px-3 py-1 bg-red-500 text-white rounded-lg hover:bg-red-600 text-sm"
              >
                Remove
              </button>
            </div>
            <div class="mb-3">
              <label class="block text-xs font-semibold text-gray-600 mb-1">Instruction *</label>
              <textarea
                v-model="step.instruction"
                rows="3"
                class="input-field text-sm"
              ></textarea>
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1">Step Image URL (optional)</label>
              <input
                v-model="step.image_url"
                type="url"
                class="input-field text-sm"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Submit Buttons -->
      <div class="flex justify-end space-x-4">
        <NuxtLink :to="`/recipes/${recipeId}`" class="btn-secondary">
          Cancel
        </NuxtLink>
        <button
          type="button"
          @click="deleteRecipe"
          class="px-6 py-3 bg-red-500 text-white font-semibold rounded-lg hover:bg-red-600"
        >
          Delete Recipe
        </button>
        <button
          type="submit"
          :disabled="submitting"
          class="btn-primary disabled:opacity-60"
        >
          <span v-if="!submitting">Update Recipe</span>
          <span v-else class="flex items-center">
            <span class="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></span>
            Updating...
          </span>
        </button>
      </div>

      <div v-if="serverError" class="p-4 bg-red-50 border border-red-200 rounded-lg text-red-600">
        {{ serverError }}
      </div>
    </form>
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuth } from '~/composables/useAuth'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_RECIPE_BY_ID, GET_CATEGORIES, UPDATE_RECIPE, DELETE_RECIPE } from '~/composables/useGraphQL'
import * as yup from 'yup'

const route = useRoute()
const router = useRouter()
const { isLoggedIn, user } = useAuth()

const recipeId = computed(() => route.params.id)
const recipe = ref(null)
const loading = ref(true)
const categories = ref([])
const submitting = ref(false)
const serverError = ref(null)

const form = reactive({
  title: '',
  description: '',
  featured_image: '',
  prep_time_minutes: null,
  cook_time_minutes: null,
  servings: null,
  difficulty: '',
  category_id: '',
  ingredients: [],
  steps: []
})

const errors = reactive({
  title: null,
  description: null,
  featured_image: null,
  prep_time_minutes: null,
  category_id: null,
  ingredients: null,
  steps: null
})

const schema = yup.object({
  title: yup.string().trim().required('Title is required'),
  description: yup.string().trim().required('Description is required'),
  featured_image: yup.string().url('Must be a valid URL').required('Featured image is required'),
  prep_time_minutes: yup.number().positive('Must be positive').required('Prep time is required'),
  category_id: yup.string().required('Category is required'),
  ingredients: yup.array().min(1, 'At least one ingredient is required'),
  steps: yup.array().min(1, 'At least one step is required')
})

// Fetch recipe
const { result: recipeResult, loading: recipeLoading } = useQuery(
  GET_RECIPE_BY_ID,
  { id: recipeId.value }
)

watch(recipeResult, (data) => {
  if (data && data.recipes_by_pk) {
    recipe.value = data.recipes_by_pk
    
    // Check if user owns this recipe
    if (!isLoggedIn.value || user.value.id !== recipe.value.user.id) {
      router.push(`/recipes/${recipeId.value}`)
      return
    }

    // Populate form
    form.title = recipe.value.title
    form.description = recipe.value.description
    form.featured_image = recipe.value.featured_image
    form.prep_time_minutes = recipe.value.prep_time_minutes
    form.cook_time_minutes = recipe.value.cook_time_minutes
    form.servings = recipe.value.servings
    form.difficulty = recipe.value.difficulty || ''
    form.category_id = recipe.value.category?.id || ''
    form.ingredients = recipe.value.ingredients.map(ing => ({
      name: ing.name,
      quantity: ing.quantity || '',
      unit: ing.unit || '',
      display_order: ing.display_order
    }))
    form.steps = recipe.value.steps.map(step => ({
      step_number: step.step_number,
      instruction: step.instruction,
      image_url: step.image_url || ''
    }))
    
    loading.value = false
  }
})

watch(recipeLoading, (val) => {
  loading.value = val
})

// Fetch categories
const { result: categoriesResult } = useQuery(GET_CATEGORIES)
watch(categoriesResult, (data) => {
  if (data) {
    categories.value = data.categories
  }
})

const addIngredient = () => {
  form.ingredients.push({
    name: '',
    quantity: '',
    unit: '',
    display_order: form.ingredients.length
  })
}

const removeIngredient = (index) => {
  form.ingredients.splice(index, 1)
  form.ingredients.forEach((ing, idx) => {
    ing.display_order = idx
  })
}

const addStep = () => {
  form.steps.push({
    step_number: form.steps.length + 1,
    instruction: '',
    image_url: ''
  })
}

const removeStep = (index) => {
  form.steps.splice(index, 1)
  form.steps.forEach((step, idx) => {
    step.step_number = idx + 1
  })
}

async function validate() {
  serverError.value = null
  Object.keys(errors).forEach((k) => (errors[k] = null))

  if (form.ingredients.length === 0) {
    errors.ingredients = 'At least one ingredient is required'
  } else {
    const invalidIngredients = form.ingredients.filter(ing => !ing.name || !ing.name.trim())
    if (invalidIngredients.length > 0) {
      errors.ingredients = 'All ingredients must have a name'
    }
  }

  if (form.steps.length === 0) {
    errors.steps = 'At least one step is required'
  } else {
    const invalidSteps = form.steps.filter(step => !step.instruction || !step.instruction.trim())
    if (invalidSteps.length > 0) {
      errors.steps = 'All steps must have instructions'
    }
  }

  try {
    await schema.validate(form, { abortEarly: false })
    return true
  } catch (err) {
    if (err.inner && err.inner.length) {
      err.inner.forEach((e) => {
        errors[e.path] = e.message
      })
    }
    return false
  }
}

async function handleSubmit(fn) {
  const ok = await validate()
  if (!ok) return
  await fn()
}

const { mutate: updateRecipe } = useMutation(UPDATE_RECIPE)

const onSubmit = async () => {
  submitting.value = true
  serverError.value = null

  try {
    const recipeData = {
      title: form.title.trim(),
      description: form.description.trim(),
      featured_image: form.featured_image.trim(),
      prep_time_minutes: form.prep_time_minutes,
      cook_time_minutes: form.cook_time_minutes || null,
      servings: form.servings || null,
      difficulty: form.difficulty || null,
      category_id: form.category_id
    }

    await updateRecipe({
      id: recipeId.value,
      recipe: recipeData
    })

    // Note: In a real app, you'd also update ingredients and steps
    // This would require additional mutations or a more complex update strategy
    router.push(`/recipes/${recipeId.value}`)
  } catch (error) {
    console.error('Error updating recipe:', error)
    serverError.value = error.message || 'Failed to update recipe. Please try again.'
  } finally {
    submitting.value = false
  }
}

const { mutate: deleteRecipeMutation } = useMutation(DELETE_RECIPE)

const deleteRecipe = async () => {
  if (!confirm('Are you sure you want to delete this recipe? This action cannot be undone.')) {
    return
  }

  try {
    await deleteRecipeMutation({ id: recipeId.value })
    router.push('/recipes')
  } catch (error) {
    console.error('Error deleting recipe:', error)
    serverError.value = error.message || 'Failed to delete recipe. Please try again.'
  }
}
</script>

