// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract HodlerCoin is ERC20("Hodler Coin", "HODLER"), Ownable {
    function mint(address to, uint256 amount) onlyOwner public {
        _mint(to, amount);
    }
}
