<template>
  <div class="min-h-screen bg-gray-100 flex flex-col items-center justify-center">
    <UserInfo v-if="user" />
    <div v-else>
      <LoginForm />
      <RegisterForm />
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed } from 'vue';
import { useStore } from 'vuex';
import LoginForm from './components/LoginForm.vue';
import RegisterForm from './components/RegisterForm.vue';
import UserInfo from './components/UserInfo.vue';

const store = useStore();
const user = computed(() => store.state.auth.user);
onMounted(() => {
  store.dispatch('auth/fetchUser');
});
</script>
