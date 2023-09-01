import { createApp } from "vue";
import App from "./App.vue";
import { createPinia, PiniaVuePlugin } from "pinia";
import vuetify from "./plugins/vuetify";
import { loadFonts } from "./plugins/webfontloader";
import router from "./router";
import piniaPluginPersistedState from "pinia-plugin-persistedstate";
import ToastPlugin from 'vue-toast-notification';
// Import one of the available themes
//import 'vue-toast-notification/dist/theme-default.css';
import 'vue-toast-notification/dist/theme-bootstrap.css';
const pinia = createPinia();
//pinia.use(piniaPluginPersistedState);
loadFonts();
const app = createApp(App);
app.use(ToastPlugin);
app.config.globalProperties.$store = {};

app.use(PiniaVuePlugin).use(router).use(pinia).use(vuetify).mount("#app");
