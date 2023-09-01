<template>
  <v-card class="mx-auto" max-width="344">
    <v-img :src="publicGoodImage" height="200px" contain></v-img>

    <v-card-title>
      Project URL: <a :href="publicGood.url">Here</a>
    </v-card-title>

    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn
        :color="$store.userStore.colors.primary"
        variant="text"
        @click="navigateToBranches"
      >
        View Branches
      </v-btn>
    </v-card-actions>

    <v-expand-transition>
      <div v-show="show">
        <v-divider></v-divider>
      </div>
    </v-expand-transition>
  </v-card>
</template>
<script>
export default {
  data: () => ({
    show: false,
  }),
  computed: {
    publicGoodImage() {
      return "https://git-scm.com/images/logos/downloads/Git-Icon-Black.png";
    },
  },
  methods: {
    navigateToBranches() {
      this.$store.userStore.setSelectedPublicGood(this.publicGood);
      this.$router.push({
        path: "/branches",
      });
    },
  },
  props: {
    publicGood: {
      type: Object,
      required: true,
    },
  },
  beforeMount(){
    console.log("publicGoodaa: ",this.publicGood)
  }
};
</script>
