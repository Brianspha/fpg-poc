<template>
  <v-dialog
    transition="dialog-bottom-transition"
    width="auto"
    v-model="$store.userStore.enableProjectStatus"
  >
    <v-card>
      <v-card>
        <v-toolbar
          style="text-align: start"
          :color="$store.userStore.colors.primary"
          :title="
            'Update Feature Status ' +
            $store.userStore.selectedFeature.featureName
          "
        ></v-toolbar>
        <v-card-text>
          <v-sheet width="300" class="mx-auto">
            <v-form ref="form">
              <v-select
                :color="$store.userStore.colors.primary"
                v-model="status"
                :items="statuses"
                density="comfortable"
                label="Status"
              ></v-select>
            </v-form>
          </v-sheet>
        </v-card-text>
        <v-card-actions class="justify-end">
          <v-btn
            variant="text"
            @click="$store.userStore.hideProjectStatusDialog"
            >Close</v-btn
          >
          <v-spacer></v-spacer>
          <v-btn
            variant="text"
            :color="$store.userStore.colors.primary"
            @click="updateProjectStatus"
            >Update</v-btn
          >
        </v-card-actions>
      </v-card>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  data: () => ({
    amount: 0,
    dialogVisible: false,
    statuses: ["More Funding Needed", "Completed"],
    status: "",
    amountRules: [(v) => !!v || "Status is required"],
  }),
  methods: {
    async updateProjectStatus() {
      const { valid } = await this.$refs.form.validate();
      try {
        if (valid) {
          this.$store.userStore.showLoading();
          this.$storeToRefs.userStore.fpgContract.methods
            .updateFeatureStatus(
              this.$store.userStore.web3.utils.toHex(
                this.$store.userStore.selectedFeature.branch.url
              ),
              this.$store.userStore.web3.utils.toHex(
                this.$store.userStore.selectedFeature.featureName
              ),
              this.status === "More Funding Needed" ? 3 : 0
            )
            .send({ from: this.$store.userStore.userAddress, gas: 6000000 });
          this.$store.userStore.hideLoading();
          this.$toast.open({
            type: "success",
            position: "top-left",
            message: "Feature development status updated",
          });
        }
      } catch (error) {
        this.$store.userStore.hideLoading();
        this.$toast.open({
          type: "error",
          position: "top-left",
          message: "Something went wrong while updating feature development status",
        });
        console.log("error updating status: ", error);
      }
    },
  },
  beforeMount() {
    console.log(
      "$store.userStore.showFundDialog: ",
      this.$store.userStore.enableFundingDialog
    );
  },
};
</script>
