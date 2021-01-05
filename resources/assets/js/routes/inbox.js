window.Vue = require('vue');
// Inbound Component
const InboxList = Vue.component('InboxList', require('../views/inbox/list.vue').default);

export default [
    // inbound route
    {name: 'InboxList', path: '/inbox-list/:from/:to', component: InboxList},
];