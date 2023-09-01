<template>
  <v-dialog
    transition="dialog-bottom-transition"
    width="auto"
    v-model="$store.userStore.enableFundingDialog"
  >
    <v-card>
      <v-card>
        <v-toolbar
          style="text-align: start"
          :color="$store.userStore.colors.primary"
          :title="'Funding ' + $store.userStore.selectedFeature.featureName"
        ></v-toolbar>
        <v-card-text>
          <v-sheet width="300" class="mx-auto">
            <v-form ref="form">
              <v-text-field
                :color="$store.userStore.colors.primary"
                v-model="amount"
                :rules="amountRules"
                label="Amount"
              ></v-text-field>
            </v-form>
          </v-sheet>
        </v-card-text>
        <v-card-actions class="justify-end">
          <v-btn variant="text" @click="$store.userStore.hideFundDialog"
            >Close</v-btn
          >
          <v-spacer></v-spacer>
          <v-btn
            variant="text"
            :color="$store.userStore.colors.primary"
            @click="fundFeature"
            >Fund</v-btn
          >
        </v-card-actions>
      </v-card>
    </v-card>
  </v-dialog>
</template>

<script>
import bigNumber from "bignumber.js";
export default {
  data: () => ({
    amount: 0,
    dialogVisible: false,
    amountRules: [
      (value) => {
        if (!isNaN(value) && value > 0) return true;

        return "Invalid Number";
      },
    ],
  }),
  methods: {
    async fundFeature() {
      const { valid } = await this.$refs.form.validate();
      try {
        if (valid) {
          console.log(
            "before: ",
            this.$store.userStore.web3.utils.toHex(
              this.$store.userStore.selectedFeature.url
            ),
            this.$store.userStore.web3.utils.toHex(
              this.$store.userStore.selectedFeature.branchName
            )
          );
          this.$store.userStore.showLoading();
          const amount = new bigNumber(this.amount)
            .multipliedBy(
              new bigNumber(10).pow(
                new bigNumber(this.$store.userStore.decimals)
              )
            )
            .toFixed(0);
          const approved = await this.approveFPG(amount);
          if (approved) {
            this.$store.userStore.fpgContract.methods
              .fundFeature(
                this.$store.userStore.web3.utils.toHex(
                  this.$store.userStore.selectedFeature.url
                ),
                this.$store.userStore.web3.utils.toHex(
                  this.$store.userStore.selectedFeature.branchName
                ),
                amount
              )
              .send({ from: this.$store.userStore.userAddress,gas:6000000 });
            this.$toast.open({
              type: "success",
              position: "top-left",
              message: "Feature Funded",
            });
            this.$store.userStore.hideLoading();
            this.$store.userStore.hideFundDialog();
            this.$router.push("/")
          }
        }
      } catch (error) {
        this.$store.userStore.hideLoading();
        this.$toast.open({
          type: "error",
          position: "top-left",
          message: "Something went went, error funding feature",
        });
        console.error("error funding feature: ", error);
      }
    },
    async approveFPG(amount) {
      try {
        this.$store.userStore.tokenContract.methods
          .approve(import.meta.env.VITE_FPG_ADDRESS, amount)
          .send({ from: this.$store.userStore.userAddress,gas:6000000 });
        this.$toast.open({
          type: "success",
          position: "top-left",
          message: "Approved FPG Contract",
        });
        return true;
      } catch (error) {
        this.$toast.open({
          type: "error",
          position: "top-left",
          message: "Something went went, error approving FPG Contract",
        });
        console.log("error approving FPGContract: ", error);
        return false;
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
