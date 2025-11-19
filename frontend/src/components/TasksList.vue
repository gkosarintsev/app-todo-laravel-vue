<template>
  <div class="max-w-2xl mx-auto p-4">
    <h2 class="text-xl font-bold mb-4">Мои задачи</h2>
    <div v-if="loading">Загрузка...</div>
    <div v-else-if="error" class="text-red-500">{{ error }}</div>
    <div v-else>
      <table class="w-full border">
        <thead>
          <tr>
            <th>Заголовок</th>
            <th>Статус</th>
            <th>Приоритет</th>
            <th>Дедлайн</th>
            <th>Проект</th>
            <th>Важность</th>
            <th>Тест-метка</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="task in tasks" :key="task.id">
            <td>{{ task.title }}</td>
            <td>{{ task.status }}</td>
            <td>{{ task.priority }}</td>
            <td>{{ task.due_date }}</td>
            <td>{{ task.karada_project }}</td>
            <td>{{ task.importance_score }}</td>
            <td>{{ task.karada_test_label }}</td>
            <td>
              <button @click="$emit('edit', task)" class="px-2 py-1 bg-blue-500 text-white rounded">Редактировать</button>
              <button @click="deleteTask(task.id)" class="px-2 py-1 bg-red-500 text-white rounded ml-2">Удалить</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import { fetchTasks, deleteTask as apiDeleteTask } from '../services/tasks';

const tasks = ref([]);
const loading = ref(false);
const error = ref(null);

async function loadTasks() {
  loading.value = true;
  error.value = null;
  try {
    const { data } = await fetchTasks();
    tasks.value = data;
  } catch (e) {
    error.value = e.response?.data?.message || 'Ошибка';
  } finally {
    loading.value = false;
  }
}

async function deleteTask(id) {
  if (!confirm('Удалить задачу?')) return;
  try {
    await apiDeleteTask(id);
    await loadTasks();
  } catch (e) {
    error.value = e.response?.data?.message || 'Ошибка';
  }
}

onMounted(loadTasks);
</script>

