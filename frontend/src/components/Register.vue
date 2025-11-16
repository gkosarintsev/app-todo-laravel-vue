<template>
  <form @submit.prevent="onSubmit" class="space-y-3">
    <input v-model="name" placeholder="Name" class="w-full p-2 border" />
    <input v-model="email" type="email" placeholder="Email" class="w-full p-2 border" />
    <input v-model="password" type="password" placeholder="Password" class="w-full p-2 border" />
    <input v-model="password_confirmation" type="password" placeholder="Confirm password" class="w-full p-2 border" />
    <button class="px-3 py-2 bg-blue-600 text-white rounded">Register</button>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useStore } from 'vuex'

const store = useStore()
const name = ref('')
const email = ref('')
const password = ref('')
const password_confirmation = ref('')

async function onSubmit() {
  await store.dispatch('auth/register', { name: name.value, email: email.value, password: password.value, password_confirmation: password_confirmation.value })
}
</script>

