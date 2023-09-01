<template>
  <v-dialog
    transition="dialog-bottom-transition"
    width="auto"
    v-model="$store.userStore.enableAddProjectDialog"
  >
    <v-card width="70vw">
      <v-toolbar
        style="text-align: start"
        :color="$store.userStore.colors.primary"
        title="Add New Project"
      ></v-toolbar>
      <v-card-text>
        <v-form ref="form">
          <v-text-field
            :color="$store.userStore.colors.primary"
            v-model="githubURL"
            :rules="githubURLRules"
            label="Github URL"
          ></v-text-field>
          <v-select
            v-if="branches.length > 0"
            :color="$store.userStore.colors.primary"
            v-model="branch"
            :items="branches"
            density="comfortable"
            label="Found Branches"
          ></v-select>
          <v-text-field
            v-if="branches.length > 0"
            :color="$store.userStore.colors.primary"
            v-model="featureName"
            label="Feature Name"
          ></v-text-field>
          <v-row v-if="branches.length > 0">
            <v-col>
              <v-text-field
                :color="$store.userStore.colors.primary"
                v-model="duration"
                :rules="amountRules"
                label="Duration"
                hint="4"
              ></v-text-field
            ></v-col>
            <v-col
              ><v-select
                :color="$store.userStore.colors.primary"
                v-model="unit"
                :items="units"
                density="comfortable"
                label="Unit"
              ></v-select
            ></v-col>
          </v-row>
          <v-row>
            <VueDatePicker
              v-model="startDate"
              v-if="branches.length > 0"
              teleport-center
            ></VueDatePicker>
          </v-row>
        </v-form>
      </v-card-text>
      <v-card-actions class="justify-end">
        <v-btn variant="text" @click="$store.userStore.hideFundDialog"
          >Close</v-btn
        >
        <v-spacer></v-spacer>
        <v-btn
          :color="$store.userStore.colors.primary"
          @click="getProjectBranches"
        >
          Get Branches
        </v-btn>
        <v-spacer></v-spacer>
        <v-btn
          v-if="branches.length > 0"
          :color="$store.userStore.colors.primary"
          @click="addProject"
        >
          Add Project
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import VueDatePicker from "@vuepic/vue-datepicker";
import axios from "axios";
import moment from "moment";
import "@vuepic/vue-datepicker/dist/main.css";
export default {
  components: {
    VueDatePicker,
  },
  data: () => ({
    startDate: {},
    featureName: "",
    duration: 0,
    currentStep: 1,
    amount: 0,
    dialogVisible: false,
    githubURL: "",
    branches: [],
    branch: "",
    units: ["Day", "Week", "Month"],
    unit: "",
    githubURLRules: [
      (value) => {
        const githubRepoRegex =
          /^(?:https?:\/\/)?(?:www\.)?github\.com\/[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+$/;

        if (value && githubRepoRegex.test(value)) return true;

        return "Invalid Github repo";
      },
    ],
  }),
  methods: {
    async addProject() {
      try {
        this.$store.userStore.showLoading();
        console.log(" address: ", this.$store.userStore.userAddress);
        const projectExists = await this.$store.userStore.fpgContract.methods
          .projectActive(this.$store.userStore.web3.utils.toHex(this.githubURL))
          .call({ from: this.$store.userStore.userAddress, gas: 6000000 });
        console.log("projectActive: ", projectExists);
        if (!projectExists) {
          const receipt = await this.$store.userStore.fpgContract.methods
            .addProject(this.$store.userStore.web3.utils.toHex(this.githubURL))
            .send({ from: this.$store.userStore.userAddress, gas: 6000000 });
          console.log("project added receipt: ", receipt);
        }
        console.log(moment(this.startDate).valueOf(), this.duration, this.unit);
        const duration =
          this.unit === "Day"
            ? this.duration * 86400
            : this.unit === "Week"
            ? this.duration * 604800
            : this.duration * 2629746;
        console.log(
          this.$store.userStore.web3.utils.toHex(this.githubURL),
          this.$store.userStore.web3.utils.toHex(this.branch),
          this.$store.userStore.web3.utils.toHex(this.featureName),
          moment(this.startDate).valueOf() / 1000,
          this.duration
        );
        const fundingRequest = await this.$store.userStore.fpgContract.methods
          .requestFeatureFunding(
            this.$store.userStore.web3.utils.toHex(this.githubURL),
            this.$store.userStore.web3.utils.toHex(this.branch),
            this.$store.userStore.web3.utils.toHex(this.featureName),
            moment(this.startDate).valueOf() / 1000,
            duration
          )
          .send({ from: this.$store.userStore.userAddress, gas: 6000000 });
        console.log("fundingRequest: ", fundingRequest);

        this.$store.userStore.hideLoading();
        window.location.reload();
      } catch (error) {
        console.error("error adding project", error);
        this.$store.userStore.hideLoading();
      }
    },
    async getProjectBranches() {
      try {
        this.$store.userStore.showLoading();
        const [, owner, repo] = this.githubURL.match(
          /github\.com\/([^/]+)\/([^/]+)/i
        );
        const response = await axios.get(
          `https://api.github.com/repos/${owner}/${repo}/branches`
        );
        this.branches = response.data.map((branch) => branch.name);
        this.branch = this.branches.length > 0 ? this.branches[0] : "";
        this.$store.userStore.hideLoading();

        this.$toast.open({
          type: "success",
          position: "top-left",
          message: `Found ${this.branches.length} branches`,
        });
      } catch (error) {
        this.$store.userStore.hideLoading();
        this.$toast.open({
          type: "error",
          position: "top-left",
          message: "Something went went, no branches were found",
        });
      }
    },
  },
};
</script>
