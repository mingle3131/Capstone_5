const hre = require("hardhat");

async function main() {
  const EscrowFactory = await hre.ethers.getContractFactory("escrow"); // 컨트랙트 이름은 정확히 대소문자 일치
  const escrow = await EscrowFactory.deploy();                         // 인스턴스 생성

  await escrow.waitForDeployment();                                    // ethers v6용
  const address = await escrow.getAddress();                           // ethers v6용 주소

  console.log(`✅ Escrow deployed at: ${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
