<template>
  <v-card class="mx-auto" max-width="auto" align="start" justify="start">
    <v-img
      src="https://cdn0.iconfinder.com/data/icons/octicons/1024/git-branch-512.png"
      height="200px"
      contain
    ></v-img>

    <v-card-title>
      <div v-for="item in cardItems" :key="item.icon">
        <v-row align="start" justify="start" class="paddingBottom">
          <v-icon end :icon="item.icon"></v-icon>
          <p class="textStyle">{{ item.text }}</p>
        </v-row>
      </div>
      <v-row align="center" justify="center" class="paddingBottom">
        <v-icon end icon="mdi-timer-sand"></v-icon>
        <v-progress-linear
          v-model="progress"
          :color="$store.userStore.colors.primary"
          height="25"
        >
          <template v-slot:default="{ value }">
            <strong>{{ value }}%</strong>
          </template>
        </v-progress-linear>
      </v-row>
    </v-card-title>
    <v-card-actions>
      <v-btn
        v-if="
          $store.userStore.userAddress === branch.owner 
        "
        :color="$store.userStore.colors.primary"
        variant="text"
        @click="startProject"
      >
        Start Project
      </v-btn>
      <v-spacer></v-spacer>
      <v-btn
        v-if="
          $store.userStore.userAddress === branch.owner 
        "
        :color="$store.userStore.colors.primary"
        variant="text"
        @click="updateProjectStatus"
      >
        Update Project Status
      </v-btn>
      <v-spacer></v-spacer>
      <v-btn
        v-if="$store.userStore.userAddress !== branch.owner"
        :color="$store.userStore.colors.primary"
        variant="text"
        @click="handleFundClick"
      >
        Fund
      </v-btn>
    </v-card-actions>
    <fund-public-good></fund-public-good>
    <update-project-status></update-project-status>
  </v-card>
</template>

<script>
import bigNumber from "bignumber.js";
import FundPublicGood from "../dialog/FundPublicGood.vue";
import UpdateProjectStatus from "../dialog/UpdateProjectStatus.vue";

export default {
  data: () => ({
    progress: 0,
    cardItems: [],
  }),
  props: {
    branch: {
      type: Object,
      required: true,
    },
  },
  components: { FundPublicGood, UpdateProjectStatus },
  methods: {
    async updateProjectStatus() {
      this.$store.userStore.showProjectStatusDialog();
    },
    async startProject() {
      try {
        this.$store.userStore.showLoading();
        this.$store.userStore.fpgContract.methods
          .startProject(
            this.$store.userStore.web3.utils.toHex(this.branch.url),
            this.$store.userStore.web3.utils.toHex(this.branch.featureName)
          )
          .send({ from: this.$store.userStore.userAddress, gas: 6000000 });
        this.$store.userStore.hideLoading();
        this.$toast.open({
          type: "success",
          position: "top-left",
          message: "Feature development started",
        });
      } catch (error) {
        this.$store.userStore.hideLoading();
        this.$toast.open({
          type: "error",
          position: "top-left",
          message: "Something went wrong while starting feature development",
        });
        console.log("error starting feature development : ", error);
      }
    },
    handleFundClick() {
      this.$store.userStore.setSelectedFeature(this.branch);
      this.$store.userStore.showFundDialog();
    },
  },
  beforeMount() {
    const progress = new bigNumber(this.branch.streamedSoFar)
      .dividedBy(this.branch.fundsCommitted)
      .multipliedBy(100)
      .toFixed(2);
    this.progress = isNaN(progress) ? 0 : progress;
    this.cardItems = [
      {
        icon: "mdi-alpha-n",
        text: this.branch.featureName,
      },
      {
        icon: "mdi-timeline-check",
        text: `${this.branch.duration / 86400n} days`,
      },
      {
        icon: "mdi-calendar-range",
        text: this.branch.startDate,
      },
      {
        icon: "mdi-ethereum",
        text: this.branch.fundsCommitted,
      },
      {
        icon: "mdi-update",
        text: this.branch.status,
      },
    ];
  },
};
</script>

<style scoped>
.textStyle {
  font-size: 14px;
  padding-left: 5%;
}

.paddingBottom {
  padding-top: 5%;
}
</style>
