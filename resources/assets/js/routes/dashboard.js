window.Vue = require('vue');

const Dashboard = Vue.component('Dashboard', require('../views/dashboard/dashboard.vue').default);

export default [
    {name: 'Dashboard', path: '/', component: Dashboard},
    {name: 'Dashboard', path: '/dashboard', component: Dashboard},
];