// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/NzhlCoin.sol";

contract NzhlCoinTest is Test {
    NzhlCoin public coin;

    function setUp() public {
        coin = new NzhlCoin();
    }

    function testName() public {
      string memory name = coin.name();
      assertEq(name, "Nzhl Coin");
    }

    function testSymbol() public {
      string memory name = coin.symbol();
      assertEq(name, "NZHL");
    }
}
