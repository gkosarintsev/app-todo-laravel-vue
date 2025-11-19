<template>
  <div class="w-full max-w-7xl mx-auto p-4">
    <h2 class="text-2xl font-bold mb-6 text-center">Мои задачи</h2>
    <div v-if="loading">Загрузка...</div>
    <div v-else-if="error" class="text-red-500">{{ error }}</div>
    <div v-else>
      <table class="table-auto w-full border rounded-lg overflow-hidden shadow">
        <thead class="bg-gray-100">
          <tr>
            <th class="px-3 py-2 font-bold">Заголовок</th>
            <th class="px-3 py-2 font-bold">Статус</th>
            <th class="px-3 py-2 font-bold">Приоритет</th>
            <th class="px-3 py-2 font-bold">Дедлайн</th>
            <th class="px-3 py-2 font-bold">Проект</th>
            <th class="px-3 py-2 font-bold">Важность</th>
            <th class="px-3 py-2 font-bold">Тест-метка</th>
            <th class="px-3 py-2 font-bold"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(task, i) in tasks" :key="task.id" :class="i % 2 === 0 ? 'bg-white' : 'bg-gray-50'">
            <td class="px-3 py-2">{{ task.title }}</td>
            <td class="px-3 py-2">{{ task.status }}</td>
            <td class="px-3 py-2">{{ task.priority }}</td>
            <td class="px-3 py-2">{{ formatDate(task.due_date) }}</td>
            <td class="px-3 py-2">{{ task.karada_project }}</td>
            <td class="px-3 py-2">{{ task.importance_score }}</td>
            <td class="px-3 py-2">{{ task.karada_test_label }}</td>
            <td class="px-3 py-2 flex items-center space-x-2">
              <button @click="$emit('edit', task)" class="text-blue-500 hover:text-blue-700">
                <i class="fas fa-edit"></i>
              </button>
              <button @click="deleteTask(task.id)" class="text-red-500 hover:text-red-700">
                <i class="fas fa-trash"></i>
              </button>
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

function formatDate(val) {
  if (!val) return '';
  // If it's already a string ISO like '2025-12-01T00:00:00.000000Z'
  if (typeof val === 'string') {
    const tIndex = val.indexOf('T');
    if (tIndex > -1) return val.slice(0, tIndex);
    // fallback: try to parse as date
    try {
      const d = new Date(val);
      if (!isNaN(d)) return d.toISOString().slice(0, 10);
    } catch (e) {}
    return val;
  }

  // If it's a Date object or numeric timestamp
  try {
    const d = new Date(val);
    if (!isNaN(d)) return d.toISOString().slice(0, 10);
  } catch (e) {}
  return '';
}

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
