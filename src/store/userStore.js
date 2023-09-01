/*
 *@dev This file needs to be refactored into smaller stores
 */

import { defineStore, acceptHMRUpdate } from "pinia";
import detectEthereumProvider from "@metamask/detect-provider";
import bigNumber from "bignumber.js";
import swal from "sweetalert2"; // Make sure to import the correct SweetAlert library
import token from "../../out/FPGToken.sol/FPGToken.json";
import fpg from "../../out/FPG.sol/FPG.json";
import lockupLinear from "../../out/SablierV2LockupLinear.sol/SablierV2LockupLinear.json";

import Web3 from "web3";
import moment from "moment";
const web3 = new Web3(
  new Web3.providers.HttpProvider(import.meta.env.VITE_RPC_ENDPOINT)
);

export const userStore = defineStore({
  id: "userStore",
  persist: {
    enabled: true,
  },
  state: () => ({
    enableAddProjectDialog: true,
    myPublicGoods: [],
    decimals: 0,
    web3: web3,
    tokenSymbol: "",
    tokenBalance: 0,
    userAddress: "",
    isLoading: false,
    isConnected: false,
    colors: { primary: "amber" },
    loggedIn: false,
    loadingZIndex: 0,
    chainId: "",
    tokenABI: token.abi,
    fpgABI: fpg.abi,
    lockupLinearContract: new web3.eth.Contract(
      lockupLinear.abi,
      import.meta.env.VITE_SABLIER_LOCKUP_LINEAR_ADDRESS
    ),
    fpgContract: new web3.eth.Contract(
      fpg.abi,
      import.meta.env.VITE_FPG_ADDRESS
    ),
    tokenContract: new web3.eth.Contract(
      token.abi,
      import.meta.env.VITE_TOKEN_ADDRESS
    ),
    selectedFeature: {},
    enableFundingDialog: false,
    selectedPublicGood: {},
    enableProjectStatus: false,
    enableFundingDialog: false,
    publicGoods: [],
  }),
  actions: {
    setSelectedPublicGood(publicGood) {
      this.selectedPublicGood = publicGood;
    },
    async getProjectBranches(publicGood) {
      let branchDetails = [];
      try {
        for (let i = 0; i < publicGood.branches.length; i++) {
          const branchDetail = await this.fpgContract.methods
            .getFeatureDetails(
              web3.utils.toHex(publicGood.url),
              web3.utils.toHex(publicGood.branches[i])
            )
            .call({ from: this.userAddress });
          console.log("branchDetail: ", branchDetail);
          const streamedSoFar = await this.getStreamedAmount(branchDetail["0"]);

          branchDetails.push({
            url: publicGood.url,
            branchName: publicGood.branches[i],
            owner: branchDetail["0"],
            featureName: this.web3.utils.hexToUtf8(branchDetail["1"]),
            duration: branchDetail["2"],
            startDate: moment(Number(branchDetail["3"]) * 1000).format("LLL"),
            fundsCommitted: new bigNumber(branchDetail["4"])
              .dividedBy(new bigNumber(10).pow(new bigNumber(this.decimals)))
              .toFixed(2),
            status:
              branchDetail["5"].toString() === 1n
                ? "Completed"
                : branchDetail["5"].toString() === 2n
                ? "In Progress"
                : "FundingPhase",
            streamedSoFar: new bigNumber(streamedSoFar)
              .dividedBy(new bigNumber(10).pow(new bigNumber(this.decimals)))
              .toFixed(2),
          });
        }
      } catch (error) {
        console.error(error);
      }
      console.log("branchDetails: ", branchDetails);
      return branchDetails;
    },
    async getStreamedAmount(address) {
      try {
        return await this.lockupLinearContract.methods
          .streamedAmountOf(address)
          .call({ from: this.userAddress });
      } catch (error) {
        return 0;
      }
    },
    async getPublicGoods() {
      let goods = [];
      try {
        const publicGoods = await this.fpgContract.methods
          .getProjectURLs()
          .call({ from: this.userAddress });
        console.log("publicGoods: ", publicGoods);

        for (let i = 0; i < publicGoods.length; i++) {
          const projectDetails = await this.fpgContract.methods
            .getProjectDetails(publicGoods[i])
            .call({ from: this.userAddress });
          console.log(
            "projectDetails: ",
            this.web3.utils.hexToUtf8(publicGoods[i])
          );
          goods.push({
            owner: web3.utils.toChecksumAddress(projectDetails["0"]),
            url: this.web3.utils.hexToUtf8(publicGoods[i]),
            branches: projectDetails["1"].map((branch) =>
              web3.utils.hexToUtf8(branch)
            ),
          });
        }
      } catch (error) {
        console.error("error fetching public goods: ", error);
      }
      this.myPublicGoods = goods.filter(
        (good) =>
          web3.utils.toChecksumAddress(good.owner) ===
          web3.utils.toChecksumAddress(this.userAddress)
      );
      this.publicGoods = goods.filter(
        (good) =>
          web3.utils.toChecksumAddress(good.owner) !==
          web3.utils.toChecksumAddress(this.userAddress)
      );
      console.log(" this.myPublicGoods: ", this.myPublicGoods, goods);
    },
    setSelectedFeature(newFeature) {
      this.selectedFeature = newFeature;
    },
    showFundDialog() {
      this.enableFundingDialog = true;
    },
    hideFundDialog() {
      this.enableFundingDialog = false;
    },
    showProjectStatusDialog() {
      this.enableProjectStatus = true;
    },
    hideProjectStatusDialog() {
      this.enableProjectStatus = false;
    },
    showAddProjectDialog() {
      this.enableAddProjectDialog = true;
    },
    hideAddProjectDialog() {
      this.enableAddProjectDialog = false;
    },
    showLoading() {
      this.isLoading = true;
    },
    hideLoading() {
      this.isLoading = false;
    },
    async getBalance() {
      const symbol = await this.tokenContract.methods
        .symbol()
        .call({ from: this.userAddress });
      const balance = await this.tokenContract.methods
        .balanceOf(this.userAddress)
        .call({ from: this.userAddress });
      const decimals = await this.tokenContract.methods
        .decimals()
        .call({ from: this.userAddress });
      this.tokenBalance = new bigNumber(balance)
        .dividedBy(new bigNumber(10).pow(new bigNumber(decimals)))
        .toFixed(2);
      this.tokenSymbol = symbol;
      this.decimals = decimals;
      console.log(
        `tokenBalance: ${this.tokenBalance} symbol: ${this.tokenSymbol}`
      );
    },
    async connectWallet() {
      this.showLoading();
      const provider = await detectEthereumProvider();
      this.hideLoading();
      // console.log("Provider: ", await window?.ethereum?.isConnected());
      if (provider && !(await window?.ethereum?.isConnected())) {
        const accounts = await window.ethereum
          .request({ method: "eth_requestAccounts" })
          .catch(async (error) => {
            this.hideLoading();
            switch (error.code) {
              case -32002:
                this.warning({
                  warning:
                    "Please check to see if a request to access your metamask has not been sent. It seems like you have not accepted",
                });
                break;
              case 4001:
                this.errorWithFooterMetamask({
                  message: "Please install metamask to use the DApp",
                });
                break;
              default:
                this.isConnected = true;
                this.userAddress = web3.utils.toChecksumAddress(accounts[0]);
                await Promise.all([
                  this.getBalance(),
                  this.setupListeners(),
                  this.getPublicGoods(),
                ]);

              //  console.log(
              //  `Switching to already connected account ${this.userAddress}`
              //);
            }
          });
      } else if (provider && (await window?.ethereum?.isConnected())) {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        this.hideLoading();
        this.isConnected = true;
        this.userAddress = web3.utils.toChecksumAddress(accounts[0]);
        await Promise.all([
          this.getBalance(),
          this.setupListeners(),
          this.getPublicGoods(),
        ]);
        // console.log(
        //    `Switching to already connected account ${this.userAddress}`
        //  );
      } else {
        this.errorWithFooterMetamask({
          message: "Please install metamask to use the DApp",
        });
      }
    },
    async setupListeners() {
      // const chainId = await window.ethereum.request({ method: "eth_chainId" });

      window.ethereum.on("chainChanged", async (chainId) => {
        if (chainId !== this.chainId) {
          window.location.reload();
        }
      });
      window.ethereum.on("accountsChanged", async (accounts) => {
        console.log("accounts: ", accounts);
        if (accounts.length > 0 && accounts[0] !== this.userAddress) {
          window.location.reload();
        }
      });
      //ethereum.on("disconnect", window.location.reload());
    },
    success(message) {
      swal.fire({
        position: "top-end",
        icon: "success",
        title: "Success",
        showConfirmButton: false,
        timer: 2500,
        text: message,
      });
    },
    successWithCallBack(message) {
      swal
        .fire({
          position: "top-end",
          icon: "success",
          title: "Success",
          showConfirmButton: true,
          text: message.message,
        })
        .then((results) => {
          if (results.isConfirmed) {
            message.onTap();
          }
        });
    },
    warning(message) {
      swal.fire("Warning", message.warning, "warning").then((result) => {
        /* Read more about isConfirmed, isDenied below */
        if (result.isConfirmed) {
          message.onTap();
        }
      });
    },
    error(message) {
      swal.fire("Error!", message, "error").then((result) => {
        /* Read more about isConfirmed, isDenied below */
        if (result.isConfirmed) {
          console.log("leveled");
        }
      });
    },
    successWithFooter(message) {
      swal.fire({
        icon: "success",
        title: "Success",
        text: message,
        footer: `<a href= https://etherscan/txs/${message.txHash}> View on Theta Etherscan</a>`,
      });
    },
    errorWithFooterMetamask(message) {
      swal.fire({
        icon: "error",
        title: "Error!",
        text: message.message,
        footer: `<a href= https://metamask.io> Download Metamask</a>`,
      });
    },
  },
});
if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(userStore, import.meta.hot));
}
