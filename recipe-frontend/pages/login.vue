<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-red-50 p-6">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-2xl shadow-2xl p-8">
        <div class="text-center mb-8">
          <span class="text-5xl mb-4 block">🍳</span>
          <h1 class="text-3xl font-bold text-gray-800 mb-2">Welcome Back</h1>
          <p class="text-gray-600">Sign in to continue your culinary journey</p>
        </div>

        <form @submit.prevent="handleSubmit(onSubmit)" novalidate>
          <div class="mb-5">
            <label class="block text-sm font-semibold text-gray-700 mb-2">Email</label>
            <input
              v-model="values.email"
              type="email"
              placeholder="you@example.com"
              class="input-field"
            />
            <p v-if="errors.email" class="text-red-500 text-sm mt-1">
              {{ errors.email }}
            </p>
          </div>

          <div class="mb-6">
            <label class="block text-sm font-semibold text-gray-700 mb-2">Password</label>
            <input
              v-model="values.password"
              type="password"
              placeholder="Enter your password"
              class="input-field"
            />
            <p v-if="errors.password" class="text-red-500 text-sm mt-1">
              {{ errors.password }}
            </p>
          </div>

          <button
            :disabled="submitting"
            type="submit"
            class="w-full btn-primary disabled:opacity-60 disabled:cursor-not-allowed"
          >
            <span v-if="!submitting">Sign In</span>
            <span v-else class="flex items-center justify-center">
              <span class="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></span>
              Signing in...
            </span>
          </button>

          <div v-if="serverError" class="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm">
            {{ serverError }}
          </div>
        </form>

        <p class="text-center text-sm text-gray-600 mt-6">
          Don't have an account?
          <NuxtLink to="/signup" class="text-orange-600 hover:text-orange-700 font-semibold">
            Sign up
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import * as yup from 'yup'
import { useRouter } from 'vue-router'
import { useAuth } from '~/composables/useAuth'

const router = useRouter()
const { setToken } = useAuth()

const values = reactive({
  email: '',
  password: ''
})

const errors = reactive({
  email: null,
  password: null
})

const submitting = ref(false)
const serverError = ref(null)

const schema = yup.object({
  email: yup
    .string()
    .trim()
    .email('Enter a valid email')
    .required('Email is required'),
  password: yup
    .string()
    .required('Password is required')
})

async function validate() {
  serverError.value = null
  Object.keys(errors).forEach((k) => (errors[k] = null))
  try {
    await schema.validate(values, { abortEarly: false })
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

async function onSubmit() {
  submitting.value = true
  serverError.value = null

  try {
    const res = await $fetch('http://localhost:8081/login', {
      method: 'POST',
      body: {
        email: values.email,
        password: values.password
      }
    })

    if (res && res.token) {
      setToken(res.token, { id: res.user_id, email: res.email, name: res.name })
      navigateTo('/recipes')
    } else {
      serverError.value = 'Unexpected response from server'
    }
  } catch (err) {
    if (err && err.data && err.data.error) {
      serverError.value = err.data.error
    } else if (err && err.message) {
      serverError.value = err.message
    } else {
      serverError.value = 'Login failed. Please check your credentials.'
    }
  } finally {
    submitting.value = false
  }
}
</script>

