<template>
  <v-card>
    <v-toolbar
      style="text-align: start"
      :color="$store.userStore.colors.primary"
      title="Public Good Features"
    ></v-toolbar>
    <v-container fluid>
      <v-row>
        <v-col v-for="(branch, i) in branches" :key="i" cols="12" md="4">
          <branch :branch="branch"></branch>
        </v-col>
      </v-row>
    </v-container>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn variant="text" @click="$router.push('/')"> Back </v-btn>
    </v-card-actions>
  </v-card>
</template>
<script>
import { defineComponent } from "vue";
import Branch from "../components/cards/Branch.vue";
import PublicGood from "../components/cards/PublicGood.vue";

export default defineComponent({
  components: { PublicGood, Branch },
  data: () => ({
    tab: null,
    branches: [],
    publicGood: {},
  }),
  async beforeMount() {
    console.log(
      "this.$store.userStore.selectedPublicGood: ",
      this.$store.userStore.selectedPublicGood
    );
    this.publicGood = this.$store.userStore.selectedPublicGood; // Corrected line
    this.branches = await this.$store.userStore.getProjectBranches(
      this.publicGood
    );
  },
});
</script>
