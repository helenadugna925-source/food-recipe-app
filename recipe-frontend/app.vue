<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup>
import { useAuth } from '~/composables/useAuth'

const { init } = useAuth()

onMounted(() => {
  init()
})
</script>

