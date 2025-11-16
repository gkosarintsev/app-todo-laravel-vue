import api, { getCsrfCookie } from '../services/api';

export default {
  namespaced: true,
  state: {
    user: null,
    error: null,
    loading: false,
  },
  mutations: {
    setUser(state, user) { state.user = user; },
    setError(state, error) { state.error = error; },
    setLoading(state, loading) { state.loading = loading; },
    clearError(state) { state.error = null; },
  },
  actions: {
    async fetchUser({ commit }) {
      commit('setLoading', true);
      try {
        const { data } = await api.get('/user');
        commit('setUser', data);
        commit('clearError');
      } catch (e) {
        commit('setUser', null);
        commit('setError', e.response?.data?.message || 'Ошибка');
      } finally {
        commit('setLoading', false);
      }
    },
    async login({ dispatch, commit }, payload) {
      commit('setLoading', true);
      await getCsrfCookie();
      try {
        await api.post('/login', payload);
        await dispatch('fetchUser');
        commit('clearError');
      } catch (e) {
        commit('setError', e.response?.data?.message || 'Ошибка');
      } finally {
        commit('setLoading', false);
      }
    },
    async register({ dispatch, commit }, payload) {
      commit('setLoading', true);
      await getCsrfCookie();
      try {
        await api.post('/register', payload);
        await dispatch('fetchUser');
        commit('clearError');
      } catch (e) {
        commit('setError', e.response?.data?.message || 'Ошибка');
      } finally {
        commit('setLoading', false);
      }
    },
    async logout({ commit }) {
      commit('setLoading', true);
      try {
        await api.post('/logout');
        commit('setUser', null);
        commit('clearError');
      } catch (e) {
        commit('setError', e.response?.data?.message || 'Ошибка');
      } finally {
        commit('setLoading', false);
      }
    },
  },
};
