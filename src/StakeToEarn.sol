// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "./HodlerCoin.sol";
import "./NzhlCoin.sol";

contract StakeToEarn is ReentrancyGuard, Context {
    NzhlCoin stakingToken;
    HodlerCoin rewardsToken;

    uint256 constant RAY = 10**27;


    mapping(address => uint256) public userStakedAmount;
    mapping(address => uint256) public userRewardPerTokenIndex;
    mapping(address => uint256) public rewardsAccrued;

    uint256 public lastRewardPerTokenIndex;
    uint256 public lastUpdatedTimestamp;
    uint256 public rewardEverySecond;
    uint256 public totalStakedAmount;

    constructor(address stakingTokenAddr, address rewardsTokenAddr, uint _rewardEverySecond) {
        stakingToken = NzhlCoin(stakingTokenAddr);
        rewardsToken = HodlerCoin(rewardsTokenAddr);
        rewardEverySecond = _rewardEverySecond;
    }

    function stake(uint256 amount) external nonReentrant {
        _updateIndex();

        stakingToken.transferFrom(_msgSender(), address(this), amount);
        userStakedAmount[_msgSender()] += amount;
        totalStakedAmount += amount;
    }

    function withdraw(uint256 amount) external nonReentrant {
        _updateIndex();

        stakingToken.transfer(_msgSender(), amount);
        userStakedAmount[_msgSender()] -= amount;
        totalStakedAmount -= amount;
    }

    function withdrawRewards() external nonReentrant {
        _updateIndex();

        rewardsToken.mint(_msgSender(), rewardsAccrued[_msgSender()]);
        delete rewardsAccrued[_msgSender()];
    }

    function rewardsEarned(address user) external view returns (uint256) {
        return rewardsAccrued[user] + (_getLatestRewardPerTokenIndex() - userRewardPerTokenIndex[user]) * userStakedAmount[user] / RAY;
    }

    function _updateIndex() internal {
        if (block.timestamp > lastUpdatedTimestamp) {
            lastRewardPerTokenIndex =  _getLatestRewardPerTokenIndex();

            rewardsAccrued[_msgSender()] += (lastRewardPerTokenIndex - userRewardPerTokenIndex[_msgSender()]) * userStakedAmount[_msgSender()] / RAY;

            userRewardPerTokenIndex[_msgSender()] = lastRewardPerTokenIndex;
            lastUpdatedTimestamp = block.timestamp;
        }
    }

    function _getLatestRewardPerTokenIndex() public view returns (uint256) {
        if (totalStakedAmount == 0) {
            return lastRewardPerTokenIndex;
        } else {
            return RAY * (block.timestamp - lastUpdatedTimestamp) * rewardEverySecond / totalStakedAmount + lastRewardPerTokenIndex;
        }
    }
}





















