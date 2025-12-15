// ./composables/useAuth.js
import { ref } from 'vue'

const token = ref(null)
const user = ref(null)

export function useAuth() {
  function setToken(t, userData = null) {
    token.value = t
    if (process.client) localStorage.setItem('token', t)
    // Decode JWT to get user info
    try {
      const payload = JSON.parse(atob(t.split('.')[1]))
      // Try to get user_id from Hasura claims or sub
      let userId = payload.sub
      if (payload['https://hasura.io/jwt/claims']) {
        userId = payload['https://hasura.io/jwt/claims']['x-hasura-user-id'] || userId
      }
      user.value = { 
        id: userId,
        email: payload.email || payload.sub, 
        name: userData?.name || '',
        ...payload 
      }
      if (userData) {
        user.value = { ...user.value, ...userData }
      }
    } catch (e) {
      user.value = userData || null
    }
  }

  function getToken() {
    if (token.value) return token.value
    if (process.client) {
      const t = localStorage.getItem('token')
      token.value = t
      return t
    }
    return null
  }

  function clearAuth() {
    token.value = null
    user.value = null
    if (process.client) localStorage.removeItem('token')
  }

  function isLoggedIn() {
    return !!getToken()
  }

  // call on app boot to repopulate
  async function init() {
    if (process.client) {
      const t = localStorage.getItem('token')
      if (t) {
        token.value = t
        try {
          const payload = JSON.parse(atob(t.split('.')[1]))
          user.value = { email: payload.sub, ...payload }
        } catch (e) {
          user.value = null
        }
      }
    }
  }

  return { token, user, setToken, getToken, clearAuth, isLoggedIn, init }
}
