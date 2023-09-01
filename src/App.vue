<template>
  <!-- App.vue -->

  <v-app>
    <v-app-bar app>
      <v-row v-if="$store.userStore.isConnected" align="start" justify="start">
        <v-btn
          class="ma-2"
          :color="$store.userStore.colors.primary"
          @click="$store.userStore.showAddProjectDialog"
        >
          Add Project
        </v-btn>
      </v-row>
      <v-spacer></v-spacer>
      <v-row v-if="$store.userStore.isConnected" align="start" justify="start">
        <v-row align="start" justify="start">
          <v-icon end icon="mdi-ethereum"></v-icon>
          <p class="textStyle">
            {{ $store.userStore.tokenBalance }}
            {{ $store.userStore.tokenSymbol }}
          </p>
        </v-row>
      </v-row>
      <v-spacer></v-spacer>
      <v-row align="end" justify="end">
        <v-btn
          class="ma-2"
          :color="$store.userStore.colors.primary"
          @click="$store.userStore.connectWallet"
        >
          {{
            $store.userStore.isConnected
              ? $store.userStore.userAddress.substring(0, 3) +
                "..." +
                $store.userStore.userAddress.substring(
                  $store.userStore.userAddress.length - 3,
                  $store.userStore.userAddress.length
                )
              : "Connect Wallet"
          }}
        </v-btn>
      </v-row>
    </v-app-bar>

    <!-- Sizes your content based upon application components -->
    <v-main>
      <!-- Provides the application the proper gutter -->
      <v-container fluid>
        <!-- If using vue-router -->
        <router-view />
      </v-container>

      <v-overlay
        :model-value="$store.userStore.isLoading"
        class="align-center justify-center"
      >
        <v-progress-circular
          :color="$store.userStore.colors.primary"
          indeterminate
          size="64"
        ></v-progress-circular>
      </v-overlay>
    </v-main>
    <add-project></add-project>
    <v-footer app>
      <!-- -->
    </v-footer>
  </v-app>
</template>

<script>
import { userStore } from "./store/userStore.js";
import { defineComponent } from "vue";
import AddProject from "./components/dialog/AddProject.vue";

export default defineComponent({
  components: { AddProject },
  setup() {
    return {};
  },

  beforeMount() {
    window.addEventListener("beforeunload", function () {
      // This code will run when the page is being reloaded
      this.$router.push("/");
    });
    //init stores
    this.$store.userStore = userStore();
    this.$store.userStore.connectWallet();
    console.log("this.$store.userStore: ", this.$store.userStore);
  },
});
</script>
<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}
</style>
