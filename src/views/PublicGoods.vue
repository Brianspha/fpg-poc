<template>
  <v-container fluid>
    <v-row v-if="$store.userStore.publicGoods.length > 0">
      <v-col v-for="(publicGood, i) in $store.userStore.publicGoods" :key="i" cols="12" md="4">
        <public-good :publicGood="publicGood"></public-good>
      </v-col>
    </v-row>
    <v-row justify="center" align="center" v-else>No Public Goods Found</v-row>
  </v-container>
</template>
<script>
import { defineComponent } from "vue";
import PublicGood from "../components/cards/PublicGood.vue";

export default defineComponent({
  components: { PublicGood },
  data: () => ({
    tab: null,
    publicGoods: [],
  }),
  async beforeMount() {

  },
});
</script>
