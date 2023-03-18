// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract NzhlCoin is ERC20("Nzhl Coin", "NZHL") {
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
