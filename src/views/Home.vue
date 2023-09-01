<template>
  <v-card>
    <v-tabs :color="$store.userStore.colors.primary" left>
      <v-tab v-for="({ title }, index) in pages" :key="index">
        {{ title }}
      </v-tab>
    </v-tabs>
    <v-window v-model="tab">
      <v-window-item v-for="({ page }, index) in pages" :key="index">
        <component :is="page" />
      </v-window-item>
    </v-window>
  </v-card>
</template>
<script>
import { defineComponent } from "vue";
import PublicGoods from "./PublicGoods.vue";
import MyPublicGoods from "./MyPublicGoods.vue";
export default defineComponent({
  components: { PublicGoods, MyPublicGoods },
  data: () => ({
    tab: null,
    pages: [
      {
        title: "Public Goods",
        page: PublicGoods,
      },
      {
        title: "My Public Goods",
        page: MyPublicGoods,
      },
    ],
  }),
  setup() {
    return {};
  },
});
</script>
