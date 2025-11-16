import { createApp } from 'vue';
import App from './App.vue';
import store from './store';
import './index.css';
import axios from 'axios';

// Configure axios for Sanctum
axios.defaults.withCredentials = true;
axios.defaults.baseURL = '/api'; // Use Vite proxy

createApp(App).use(store).mount('#app');
