<template>
  <div class="min-h-screen bg-gray-100 flex flex-col items-center justify-center">
    <UserInfo v-if="user" />
    <div v-else>
      <LoginForm />
      <RegisterForm />
    </div>
    <div v-if="user" class="w-full mt-8">
      <TaskForm v-if="editingTask" :task="editingTask" @saved="onSaved" @cancel="editingTask = null" />
      <TasksList v-else @edit="editTask" />
      <button v-if="!editingTask" @click="editingTask = {}" class="mt-4 px-4 py-2 bg-green-600 text-white rounded">Создать задачу</button>
    </div>
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

const store = useStore();
const user = computed(() => store.state.auth.user);
const editingTask = ref(null);

function editTask(task) {
  editingTask.value = task;
}
function onSaved() {
  editingTask.value = null;
}
onMounted(() => {
  store.dispatch('auth/fetchUser');
});
</script>
