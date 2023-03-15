// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NzhlCoin.sol";

contract Deploy is Script {

    function run() external {
        uint256 sk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(sk);
        NzhlCoin nft = new NzhlCoin();
    }
}
