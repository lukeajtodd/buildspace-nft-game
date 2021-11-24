import { ethers } from "hardhat";

const main = async () => {
  const gameContractFactory = await ethers.getContractFactory("Game");
  const gameContract = await gameContractFactory.deploy(
    ["Tidus", "Wakka", "Yuna"],
    [
      "https://i.imgur.com/mUDc2KQ.gif",
      "https://i.imgur.com/iCBiadT.jpeg",
      "https://i.imgur.com/kvCZI4B.jpeg",
    ],
    [150, 300, 100],
    [80, 50, 120],
    "Sin",
    "http://img2.wikia.nocookie.net/__cb20140201143509/finalfantasy/images/8/85/Sin_in_zanarkand_ruins.png",
    10000,
    40
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;

  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  // const returnedTokenUri = await gameContract.tokenURI(1);
  // console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exitCode = 0;
  } catch (error) {
    console.error(error);
    process.exitCode = 1;
  }
};

runMain();
