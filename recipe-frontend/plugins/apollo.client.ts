import { DefaultApolloClient } from '@vue/apollo-composable'
import { ApolloClient, InMemoryCache, createHttpLink, from } from '@apollo/client/core'
import { setContext } from '@apollo/client/link/context'

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig()

  // HTTP Link
  const httpLink = createHttpLink({
    uri: config.public.hasuraEndpoint,
  })

  // Auth Link to add headers
  const authLink = setContext((_, { headers }) => {
    // Get token from localStorage
    let token = null
    if (process.client) {
      token = localStorage.getItem('token')
    }

    return {
      headers: {
        ...headers,
        'x-hasura-admin-secret': config.public.hasuraAdminSecret,
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    }
  })

  // Create Apollo Client
  const apolloClient = new ApolloClient({
    link: from([authLink, httpLink]),
    cache: new InMemoryCache(),
    defaultOptions: {
      watchQuery: {
        fetchPolicy: 'cache-and-network',
      },
      query: {
        fetchPolicy: 'network-only',
      },
    },
  })

  // Provide Apollo Client to Vue app
  nuxtApp.vueApp.provide(DefaultApolloClient, apolloClient)
})

