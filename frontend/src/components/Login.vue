<template>
  <form @submit.prevent="onSubmit" class="space-y-3">
    <input v-model="email" type="email" placeholder="Email" class="w-full p-2 border" />
    <input v-model="password" type="password" placeholder="Password" class="w-full p-2 border" />
    <button class="px-3 py-2 bg-green-600 text-white rounded">Login</button>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useStore } from 'vuex'

const store = useStore()
const email = ref('')
const password = ref('')

async function onSubmit() {
  await store.dispatch('auth/login', { email: email.value, password: password.value })
}
</script>

