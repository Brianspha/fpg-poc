const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    console.log("Deploying SablierV2Comptroller");
    const SablierV2Comptroller = await ethers.getContractFactory(
      "SablierV2Comptroller"
    );
    const sablierV2Comptroller = await upgrades.deployProxy(
      SablierV2Comptroller,
      [process.env.DEFAULT_ADDRESS]
    );
    await sablierV2Comptroller.waitForDeployment();

    console.log(
      "SablierV2Comptroller deployed to:",
      await sablierV2Comptroller.getAddress()
    );

    console.log("Deploying SablierV2NFTDescriptor");
    const SablierV2NFTDescriptor = await ethers.getContractFactory(
      "SablierV2NFTDescriptor"
    );
    const sablierV2NFTDescriptor = await upgrades.deployProxy(
      SablierV2NFTDescriptor,
      []
    );
    await sablierV2NFTDescriptor.waitForDeployment();

    console.log(
      "SablierV2NFTDescriptor deployed to:",
      await sablierV2NFTDescriptor.getAddress()
    );

    console.log("Deploying SablierV2LockupLinear");
    const SablierV2LockupLinear = await ethers.getContractFactory(
      "SablierV2LockupLinear"
    );
    const sablierV2LockupLinear = await upgrades.deployProxy(
      SablierV2LockupLinear,
      [
        process.env.DEFAULT_ADDRESS,
        await sablierV2Comptroller.getAddress(),
        await sablierV2NFTDescriptor.getAddress(),
      ]
    );
    await sablierV2LockupLinear.waitForDeployment();

    console.log(
      "SablierV2LockupLinear deployed to:",
      await sablierV2LockupLinear.getAddress()
    );

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
      )} FPGToken to admin`
    );

    console.log("Deploying StreamCreator");
    const StreamCreator = await ethers.getContractFactory("StreamCreator");
    const streamCreator = await upgrades.deployProxy(StreamCreator, [
      await sablierV2LockupLinear.getAddress(),
      await fpgToken.getAddress(),
    ]);
    await streamCreator.waitForDeployment();

    console.log("StreamCreator deployed to:", await streamCreator.getAddress());
    console.log("Deploying FPG");
    const FPG = await ethers.getContractFactory("FPG");
    const fpg = await upgrades.deployProxy(FPG, [
      await streamCreator.getAddress(),
      false,
    ]);
    await fpg.waitForDeployment();

    console.log("FPG deployed to:", await fpg.getAddress());
  } catch (error) {
    console.error(error.toString());
  }
}

main();
