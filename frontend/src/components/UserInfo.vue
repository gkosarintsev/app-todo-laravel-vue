<template>
  <div v-if="user" class="user-block">
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
.user-block {
  @apply absolute top-4 right-4 bg-white shadow-lg rounded-lg p-4 border z-50 min-w-[220px];
}
.btn {
  @apply w-full p-2 bg-red-500 text-white rounded mt-2 hover:bg-red-600 transition;
}
</style>
