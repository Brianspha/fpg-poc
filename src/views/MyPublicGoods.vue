<template>
  <v-container fluid>
    <v-row v-if="$store.userStore.myPublicGoods.length > 0">
      <v-col
        v-for="(publicGood, i) in $store.userStore.myPublicGoods"
        :key="i"
        cols="12"
        md="4"
      >
        <public-good :publicGood="publicGood"></public-good>
      </v-col>
    </v-row>
    <v-row justify="center" align="center" v-else
      >You have no Public Goods</v-row
    >
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
    console.log("myPublicGoods: ",this.$store.userStore.myPublicGoods)
    return {};
  },
});
</script>
