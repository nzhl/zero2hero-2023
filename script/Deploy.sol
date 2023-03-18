// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/NzhlCoin.sol";
import "../src/HodlerCoin.sol";
import "../src/StakeToEarn.sol";

contract Deploy is Script {

    function run() external {
        uint256 sk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(sk);

        NzhlCoin stakingCoin = new NzhlCoin();
        HodlerCoin rewardCoin = new HodlerCoin();
        StakeToEarn lpMiningContract = new StakeToEarn(address(stakingCoin), address(rewardCoin), 1 ether);
        rewardCoin.transferOwnership(address(lpMiningContract));
    }
}
