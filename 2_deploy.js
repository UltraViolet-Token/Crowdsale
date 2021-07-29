const UVToken = artifacts.require("UVToken");
const UVTCrowdsale = artifacts.require("UVTCrowdsale");

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(UVToken, "UltraVioletIDO", "UVTIDO", "12500000000000000000000000000");
    const token = await UVToken.deployed();

    await deployer.deploy(UVTCrowdsale, 18571488, "0x1a348D033CDA6bc587c4891a22128E3cB5559EAf", token.address, "9056999306250000000000000", "7000000000000000000", 1627494600, 1627571400);
    const crowdsale = await UVTCrowdsale.deployed();

    token.transfer(crowdsale.address, await token.totalSupply())
};