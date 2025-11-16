<template>
  <form @submit.prevent="onSubmit" class="space-y-4 max-w-sm mx-auto p-4 border rounded">
    <h2 class="text-xl font-bold">Регистрация</h2>
    <input v-model="name" type="text" placeholder="Имя" class="input" required />
    <input v-model="email" type="email" placeholder="Email" class="input" required />
    <input v-model="password" type="password" placeholder="Пароль" class="input" required />
    <input v-model="password_confirmation" type="password" placeholder="Повторите пароль" class="input" required />
    <button type="submit" class="btn">Зарегистрироваться</button>
    <div v-if="error" class="text-red-500">{{ error }}</div>
  </form>
</template>
<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';

const store = useStore();
const name = ref('');
const email = ref('');
const password = ref('');
const password_confirmation = ref('');
const error = computed(() => store.state.auth.error);

const onSubmit = () => {
  store.dispatch('auth/register', {
    name: name.value,
    email: email.value,
    password: password.value,
    password_confirmation: password_confirmation.value,
  });
};
</script>
<style scoped>
.input { @apply w-full p-2 border rounded; }
.btn { @apply w-full p-2 bg-green-500 text-white rounded; }
</style>

