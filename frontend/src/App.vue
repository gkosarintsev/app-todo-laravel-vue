<template>
  <div class="min-h-screen bg-gray-100 flex flex-col items-center justify-center relative">
    <h1 class="text-3xl font-bold mt-8 mb-6 text-center">KARADA Tasks</h1>
    <UserInfo v-if="user" />
    <div v-else>
      <LoginForm />
      <RegisterForm />
    </div>
    <div v-if="user" class="w-full max-w-4xl mx-auto mt-8 px-2 sm:px-4">
      <TaskForm v-if="editingTask" :task="editingTask" @saved="onSaved" @cancel="editingTask = null" />
      <TasksList v-else @edit="editTask" />
      <div class="flex justify-center mt-6">
        <button v-if="!editingTask" @click="editingTask = {}" class="px-6 py-2 bg-green-600 text-white rounded shadow hover:bg-green-700 transition">Создать задачу</button>
      </div>
    </div>
    <Toast />
  </div>
</template>

<script setup>
import { onMounted, computed, ref } from 'vue';
import { useStore } from 'vuex';
import LoginForm from './components/LoginForm.vue';
import RegisterForm from './components/RegisterForm.vue';
import UserInfo from './components/UserInfo.vue';
import TasksList from './components/TasksList.vue';
import TaskForm from './components/TaskForm.vue';
import Toast from './components/Toast.vue';
import { showToast } from './services/toast';

const store = useStore();
const user = computed(() => store.state.auth.user);
const editingTask = ref(null);

function editTask(task) {
  editingTask.value = task;
}
function onSaved() {
  editingTask.value = null;
  showToast('Задача успешно сохранена!', 'success');
}
onMounted(() => {
  store.dispatch('auth/fetchUser');
});
</script>
