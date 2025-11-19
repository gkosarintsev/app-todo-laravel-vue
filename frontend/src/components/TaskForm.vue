<template>
  <form @submit.prevent="onSubmit" class="space-y-4 max-w-xl mx-auto p-4 border rounded shadow bg-white">
    <h2 class="text-xl font-bold mb-2 text-center">{{ isEdit ? 'Редактировать' : 'Создать' }} задачу</h2>
    <input v-model="form.title" type="text" placeholder="Заголовок" class="input" required minlength="5" maxlength="120" />
    <textarea v-model="form.description" placeholder="Описание" class="input"></textarea>
    <select v-model="form.status" class="input" required>
      <option value="new">Новая</option>
      <option value="in_progress">В работе</option>
      <option value="done">Выполнена</option>
      <option value="archived">Архив</option>
    </select>
    <input v-model.number="form.priority" type="number" min="1" max="5" placeholder="Приоритет (1-5)" class="input" required />
    <input v-model="form.due_date" type="date" class="input" />
    <select v-model="form.karada_project" class="input" required>
      <option value="karada_u">karada_u</option>
      <option value="prohuntr">prohuntr</option>
      <option value="other">other</option>
    </select>
    <div class="flex gap-2 mt-4">
      <button type="submit" class="btn" :disabled="loading">
        <span v-if="loading" class="loader"></span>
        {{ loading ? 'Сохранение...' : (isEdit ? 'Сохранить' : 'Создать') }}
      </button>
      <button v-if="isEdit" type="button" @click="$emit('cancel')" class="btn bg-gray-400 hover:bg-gray-500">Отмена</button>
    </div>
    <div v-if="error" class="text-red-500 text-center">{{ error }}</div>
  </form>
</template>
<script setup>
import { ref, watch, computed } from 'vue';
import { createTask, updateTask } from '@/services/tasks';
import { showToast } from '../services/toast';

const props = defineProps({ task: Object });
const emit = defineEmits(['saved', 'cancel']);
const isEdit = computed(() => props.task && props.task.id);
const error = ref(null);
const loading = ref(false);

const form = ref({
  title: '',
  description: '',
  status: 'new',
  priority: 1,
  due_date: '',
  karada_project: 'karada_u',
});

watch(() => props.task, (task) => {
  if (task) form.value = { ...task };
  else form.value = {
    title: '', description: '', status: 'new', priority: 1, due_date: '', karada_project: 'karada_u'
  };
}, { immediate: true });

async function onSubmit() {
  error.value = null;
  loading.value = true;
  try {
    if (isEdit.value) {
      await updateTask(props.task.id, form.value);
      showToast('Задача обновлена!', 'success');
    } else {
      await createTask(form.value);
      showToast('Задача создана!', 'success');
    }
    emit('saved');
  } catch (e) {
    error.value = e.response?.data?.message || 'Ошибка';
    showToast('Ошибка при сохранении задачи', 'error');
  } finally {
    loading.value = false;
  }
}
</script>
<style scoped>
.input { @apply w-full p-2 border rounded mb-2; }
.btn { @apply w-full p-2 bg-green-500 text-white rounded hover:bg-green-600 transition shadow; }
.loader {
  @apply inline-block w-4 h-4 border-2 border-t-transparent border-white rounded-full animate-spin mr-2;
}
</style>
