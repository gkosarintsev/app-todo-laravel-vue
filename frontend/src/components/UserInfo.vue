<template>
  <div v-if="user" class="max-w-sm mx-auto p-4 border rounded space-y-2">
    <h2 class="text-xl font-bold">Пользователь</h2>
    <div><b>Имя:</b> {{ user.name }}</div>
    <div><b>Email:</b> {{ user.email }}</div>
    <button @click="logout" class="btn">Выйти</button>
  </div>
</template>
<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';

const store = useStore();
const user = computed(() => store.state.auth.user);
const logout = () => store.dispatch('auth/logout');
</script>
<style scoped>
.btn { @apply w-full p-2 bg-red-500 text-white rounded; }
</style>

