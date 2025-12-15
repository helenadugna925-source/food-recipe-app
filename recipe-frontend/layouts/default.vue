<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader />
    <main>
      <slot />
    </main>
    <AppFooter />
  </div>
</template>

<script setup>
import AppHeader from '~/components/AppHeader.vue'
import AppFooter from '~/components/AppFooter.vue'
</script>

