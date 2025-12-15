<template>
  <div class="container mx-auto px-4 py-8 max-w-4xl">
    <h1 class="text-4xl font-bold text-gray-800 mb-8">Create New Recipe</h1>

    <form @submit.prevent="handleSubmit(onSubmit)" class="space-y-8">
      <!-- Basic Information -->
      <div class="bg-white rounded-xl shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Basic Information</h2>
        
        <div class="mb-5">
          <label class="block text-sm font-semibold text-gray-700 mb-2">Recipe Title *</label>
          <input
            v-model="form.title"
            type="text"
            placeholder="e.g., Classic Chocolate Chip Cookies"
            class="input-field"
          />
          <p v-if="errors.title" class="text-red-500 text-sm mt-1">{{ errors.title }}</p>
        </div>

        <div class="mb-5">
          <label class="block text-sm font-semibold text-gray-700 mb-2">Description *</label>
          <textarea
            v-model="form.description"
            rows="4"
            placeholder="Describe your recipe..."
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
            placeholder="https://example.com/image.jpg"
            class="input-field"
          />
          <p class="text-sm text-gray-500 mt-1">This will be used as the thumbnail</p>
          <p v-if="errors.featured_image" class="text-red-500 text-sm mt-1">{{ errors.featured_image }}</p>
        </div>

        <div v-if="form.featured_image" class="mb-6">
          <img :src="form.featured_image" alt="Featured" class="w-full h-64 object-cover rounded-lg" />
        </div>

        <div>
          <label class="block text-sm font-semibold text-gray-700 mb-2">Additional Images (URLs, one per line)</label>
          <textarea
            v-model="additionalImagesText"
            rows="3"
            placeholder="https://example.com/image1.jpg&#10;https://example.com/image2.jpg"
            class="input-field"
          ></textarea>
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
                  placeholder="e.g., Flour"
                  class="input-field text-sm"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Quantity</label>
                <input
                  v-model="ingredient.quantity"
                  type="text"
                  placeholder="e.g., 2"
                  class="input-field text-sm"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Unit</label>
                <input
                  v-model="ingredient.unit"
                  type="text"
                  placeholder="e.g., cups"
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
                placeholder="Describe this step..."
                class="input-field text-sm"
              ></textarea>
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1">Step Image URL (optional)</label>
              <input
                v-model="step.image_url"
                type="url"
                placeholder="https://example.com/step-image.jpg"
                class="input-field text-sm"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Submit Buttons -->
      <div class="flex justify-end space-x-4">
        <NuxtLink to="/recipes" class="btn-secondary">
          Cancel
        </NuxtLink>
        <button
          type="submit"
          :disabled="submitting"
          class="btn-primary disabled:opacity-60"
        >
          <span v-if="!submitting">Create Recipe</span>
          <span v-else class="flex items-center">
            <span class="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></span>
            Creating...
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
import { useRouter } from 'vue-router'
import { useAuth } from '~/composables/useAuth'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_CATEGORIES, CREATE_RECIPE } from '~/composables/useGraphQL'
import * as yup from 'yup'

const router = useRouter()
const { isLoggedIn, user } = useAuth()

// Redirect if not logged in
if (!isLoggedIn.value) {
  navigateTo('/login')
}

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

const additionalImagesText = ref('')

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

async function validate() {
  serverError.value = null
  Object.keys(errors).forEach((k) => (errors[k] = null))

  // Validate ingredients
  if (form.ingredients.length === 0) {
    errors.ingredients = 'At least one ingredient is required'
  } else {
    const invalidIngredients = form.ingredients.filter(ing => !ing.name || !ing.name.trim())
    if (invalidIngredients.length > 0) {
      errors.ingredients = 'All ingredients must have a name'
    }
  }

  // Validate steps
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
  // Update display_order
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
  // Update step numbers
  form.steps.forEach((step, idx) => {
    step.step_number = idx + 1
  })
}

// Fetch categories
const { result: categoriesResult } = useQuery(GET_CATEGORIES)
watch(categoriesResult, (data) => {
  if (data) {
    categories.value = data.categories
  }
})

// Create recipe mutation
const { mutate: createRecipe } = useMutation(CREATE_RECIPE)

const onSubmit = async () => {
  submitting.value = true
  serverError.value = null

  try {
    // Prepare recipe data
    const recipeData = {
      title: form.title.trim(),
      description: form.description.trim(),
      featured_image: form.featured_image.trim(),
      prep_time_minutes: form.prep_time_minutes,
      cook_time_minutes: form.cook_time_minutes || null,
      servings: form.servings || null,
      difficulty: form.difficulty || null,
      category_id: form.category_id,
      user_id: user.value.id,
      ingredients: {
        data: form.ingredients.map((ing, idx) => ({
          name: ing.name.trim(),
          quantity: ing.quantity.trim() || null,
          unit: ing.unit.trim() || null,
          display_order: idx
        }))
      },
      steps: {
        data: form.steps.map((step, idx) => ({
          step_number: idx + 1,
          instruction: step.instruction.trim(),
          image_url: step.image_url.trim() || null
        }))
      }
    }

    // Add additional images if provided
    if (additionalImagesText.value.trim()) {
      const imageUrls = additionalImagesText.value
        .split('\n')
        .map(url => url.trim())
        .filter(url => url)
      
      if (imageUrls.length > 0) {
        recipeData.images = {
          data: imageUrls.map((url, idx) => ({
            image_url: url,
            is_featured: false,
            display_order: idx + 1
          }))
        }
      }
    }

    const result = await createRecipe({ recipe: recipeData })

    if (result && result.data && result.data.insert_recipes_one) {
      router.push(`/recipes/${result.data.insert_recipes_one.id}`)
    } else {
      serverError.value = 'Failed to create recipe'
    }
  } catch (error) {
    console.error('Error creating recipe:', error)
    serverError.value = error.message || 'Failed to create recipe. Please try again.'
  } finally {
    submitting.value = false
  }
}

// Initialize with one ingredient and one step
onMounted(() => {
  addIngredient()
  addStep()
})
</script>

