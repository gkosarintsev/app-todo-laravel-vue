<template>
  <form @submit.prevent="onSubmit" class="space-y-4 max-w-xl mx-auto p-4 border rounded">
    <h2 class="text-xl font-bold mb-2">{{ isEdit ? 'Редактировать' : 'Создать' }} задачу</h2>
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
    <button type="submit" class="btn">{{ isEdit ? 'Сохранить' : 'Создать' }}</button>
    <button v-if="isEdit" type="button" @click="$emit('cancel')" class="btn bg-gray-400">Отмена</button>
    <div v-if="error" class="text-red-500">{{ error }}</div>
  </form>
</template>
<script setup>
import { ref, watch, computed } from 'vue';
import { createTask, updateTask } from '../services/tasks';

const props = defineProps({ task: Object });
const emit = defineEmits(['saved', 'cancel']);
const isEdit = computed(() => props.task && props.task.id);
const error = ref(null);

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
  try {
    if (isEdit.value) {
      await updateTask(props.task.id, form.value);
    } else {
      await createTask(form.value);
    }
    emit('saved');
  } catch (e) {
    error.value = e.response?.data?.message || 'Ошибка';
  }
}
</script>
<style scoped>
.input { @apply w-full p-2 border rounded; }
.btn { @apply w-full p-2 bg-green-500 text-white rounded; margin-top: 8px; }
</style>
