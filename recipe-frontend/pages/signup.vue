<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-red-50 p-6">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-2xl shadow-2xl p-8">
        <div class="text-center mb-8">
          <span class="text-5xl mb-4 block">🍳</span>
          <h1 class="text-3xl font-bold text-gray-800 mb-2">Create Your Account</h1>
          <p class="text-gray-600">Join our community of food lovers</p>
        </div>

        <form @submit.prevent="handleSubmit(onSubmit)" novalidate>
          <div class="mb-5">
            <label class="block text-sm font-semibold text-gray-700 mb-2">Full Name</label>
            <input
              v-model="values.name"
              type="text"
              placeholder="Your name"
              class="input-field"
            />
            <p v-if="errors.name" class="text-red-500 text-sm mt-1">
              {{ errors.name }}
            </p>
          </div>

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
              placeholder="At least 6 characters"
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
            <span v-if="!submitting">Create Account</span>
            <span v-else class="flex items-center justify-center">
              <span class="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></span>
              Creating...
            </span>
          </button>

          <div v-if="serverError" class="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm">
            {{ serverError }}
          </div>
          <div v-if="successMsg" class="mt-4 p-3 bg-green-50 border border-green-200 rounded-lg text-green-600 text-sm">
            {{ successMsg }}
          </div>
        </form>

        <p class="text-center text-sm text-gray-600 mt-6">
          Already have an account?
          <NuxtLink to="/login" class="text-orange-600 hover:text-orange-700 font-semibold">
            Sign in
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from "vue";
import * as yup from "yup";
import { useRouter } from "#app";
import { useAuth } from "~/composables/useAuth";

// vee-validate utilities (we'll do manual validation with yup for clarity)
const router = useRouter();
const { setToken } = useAuth();

const values = reactive({
  name: "",
  email: "",
  password: "",
});

const errors = reactive({
  name: null,
  email: null,
  password: null,
});

const submitting = ref(false);
const serverError = ref(null);
const successMsg = ref(null);

// validation schema
const schema = yup.object({
  name: yup.string().trim().required("Name is required"),
  email: yup
    .string()
    .trim()
    .email("Enter a valid email")
    .required("Email is required"),
  password: yup
    .string()
    .min(6, "Password must be at least 6 characters")
    .required("Password is required"),
});

// small helper to validate and fill errors
async function validate() {
  serverError.value = null;
  successMsg.value = null;
  Object.keys(errors).forEach((k) => (errors[k] = null));
  try {
    await schema.validate(values, { abortEarly: false });
    return true;
  } catch (err) {
    if (err.inner && err.inner.length) {
      err.inner.forEach((e) => {
        errors[e.path] = e.message;
      });
    } else {
      serverError.value = err.message || "Validation error";
    }
    return false;
  }
}

// wrapper for forms (so template can call handleSubmit)
async function handleSubmit(fn) {
  const ok = await validate();
  if (!ok) return;
  await fn();
}

// onSubmit: call your REST signup endpoint
async function onSubmit() {
  submitting.value = true;
  serverError.value = null;
  successMsg.value = null;

  try {
    // Use $fetch which is built-in in Nuxt 3
    const res = await $fetch("http://localhost:8081/signup", {
      method: "POST",
      body: {
        name: values.name,
        email: values.email,
        password: values.password,
      },
      // no credentials for now
    });

    // server returns { token: "...", user_id: "...", email: "...", name: "..." }
    if (res && res.token) {
      setToken(res.token, { id: res.user_id, email: res.email, name: res.name });
      successMsg.value = "Account created — redirecting...";
      // small delay so user sees message
      setTimeout(() => {
        navigateTo("/recipes");
      }, 700);
    } else {
      serverError.value = "Unexpected response from server";
    }
  } catch (err) {
    // show helpful message
    if (err && err.data && err.data.error) serverError.value = err.data.error;
    else if (err && err.message) serverError.value = err.message;
    else serverError.value = "Signup failed";
  } finally {
    submitting.value = false;
  }
}
</script>

<style scoped>
/* tiny extra style if you want */
</style>
