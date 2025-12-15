// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  
  modules: [
    '@nuxtjs/tailwindcss',
    '@vee-validate/nuxt'
  ],

  css: ['~/assets/css/main.css'],

  runtimeConfig: {
    public: {
      apiBase: 'http://localhost:8081',
      hasuraEndpoint: 'http://localhost:8080/v1/graphql',
      hasuraAdminSecret: 'myadminsecretkey'
    }
  }
})
