const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    const FPGToken = await ethers.getContractFactory("FPGToken");
    console.log("Deploying FPGToken");
    const fpgToken = await upgrades.deployProxy(FPGToken, ["FPGToken", "SVT"], {
      initializer: "initialize",
    });
    await fpgToken.waitForDeployment();

    console.log("FPGToken deployed to:", await fpgToken.getAddress());

    console.log("Minting  10000000000000 tokens to admin");
    const tokens = ethers.parseUnits("10000000000000", "ether");
    await fpgToken.mint("0x5aF828D07f4e403522F2E88eC544E1F7D559E29d", tokens);
    console.log(
      `Minted ${await fpgToken.balanceOf(
        "0x5aF828D07f4e403522F2E88eC544E1F7D559E29d"
      )} SuperValuableToken to admin`
    );
  } catch (error) {
    console.error(error.toString());
  }
}

main();
