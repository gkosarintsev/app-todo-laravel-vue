<template>
  <div v-if="toasts.length" class="fixed bottom-4 right-4 space-y-2 z-50">
    <div
      v-for="(toast, index) in toasts"
      :key="toast.id"
      class="px-4 py-2 rounded shadow text-white max-w-xs break-words"
      :class="{
        'bg-green-500': toast.type === 'success',
        'bg-red-500': toast.type === 'error',
      }"
    >
      {{ toast.message }}
    </div>
  </div>
</template>

<script>
import { toasts } from '../services/toast';

export default {
  setup() {
    return { toasts };
  },
};
</script>

<style scoped>
.fixed {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  z-index: 50;
}
</style>
