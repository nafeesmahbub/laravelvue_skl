window.Vue = require('vue');
// Users Component
const HistoryList = Vue.component('HistoryList', require('../views/history/list.vue').default);
const HistoryDetail = Vue.component('HistoryDetail', require('../views/history/detail.vue').default);

export default [
    // users route
    {name: 'HistoryList', path: '/history-list', component: HistoryList},
    {name: 'HistoryDetail', path: '/history-detail/:id', component: HistoryDetail},
];
