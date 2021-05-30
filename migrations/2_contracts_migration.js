var erc20Token = artifacts.require("./erc20Token.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");
var BasicMath = artifacts.require("./BasicMath.sol");

module.exports = function(deployer) {
    deployer.deploy(erc20Token, 10000, "MGS Token", 18, "MGS");
    deployer.deploy(SupplyChain);
    deployer.deploy(BasicMath);
};