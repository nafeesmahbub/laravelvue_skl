window.Vue = require('vue');
// Users Component
const Compose = Vue.component('ContactList', require('../views/compose/create.vue').default);
const ComposeEdit = Vue.component('ComposeEdit', require('../views/compose/edit.vue').default);

export default [
    // users route
    {name: 'Compose', path: '/compose', component: Compose},
    {name: 'ComposeEdit', path: '/compose-edit/:id', component: ComposeEdit},

];
