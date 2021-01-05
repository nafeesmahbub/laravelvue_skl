window.Vue = require('vue');
// Inbound Component
const OutboundList = Vue.component('OutboundList', require('../views/outbound/list.vue').default);

export default [
    // inbound route
    {name: 'OutboundList', path: '/outbound-list', component: OutboundList},
];