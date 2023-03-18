// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";

import {NzhlCoin} from "../src/NzhlCoin.sol";
import {HodlerCoin} from "../src/HodlerCoin.sol";
import {StakeToEarn} from "../src/StakeToEarn.sol";

contract IntegrationTest is Test {
    NzhlCoin public stakingCoin;
    HodlerCoin public rewardCoin;
    StakeToEarn public lpMiningContract;

    address user1;
    address user2;

    function setUp() public {
        stakingCoin = new NzhlCoin();
        rewardCoin = new HodlerCoin();
        lpMiningContract = new StakeToEarn(address(stakingCoin), address(rewardCoin), 1 ether);
        rewardCoin.transferOwnership(address(lpMiningContract));


        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testStakingCoinMint() public {
        uint256 balanceBefore = stakingCoin.balanceOf(user1);
        assertEq(balanceBefore, uint256(0));

        stakingCoin.mint(user1, 1.1 ether);

        uint256 balanceAfter = stakingCoin.balanceOf(user1);
        assertEq(balanceAfter, 1.1 ether);
    }

    function testRewardCoinMintPermission() public {
        vm.expectRevert();
        rewardCoin.mint(user1, 1 ether);
    }


    function testLpMiningSingleUserCase() public {
        stakingCoin.mint(user1, 100 ether);
        assertEq(stakingCoin.balanceOf(user1), 100 ether);

        startHoax(user1);
        stakingCoin.approve(address(lpMiningContract), 2 ** 256 - 1);

        lpMiningContract.stake(10 ether);

        skip(10);
        assertEq(lpMiningContract.rewardsEarned(user1), 10 ether);

        lpMiningContract.stake(20 ether);
        skip(3);
        assertEq(lpMiningContract.rewardsEarned(user1), 13 ether);


        lpMiningContract.withdraw(29 ether);
        skip(5);
        assertEq(lpMiningContract.rewardsEarned(user1), 18 ether);

        lpMiningContract.withdraw(1 ether);
        assertEq(lpMiningContract.totalStakedAmount(), 0 ether);

        assertEq(lpMiningContract.rewardsEarned(user1), 18 ether);


        lpMiningContract.stake(1 ether);
        skip(2);
        assertEq(lpMiningContract.rewardsEarned(user1), 20 ether);

        assertEq(rewardCoin.balanceOf(user1), 0 ether);
        lpMiningContract.withdrawRewards();
        assertEq(lpMiningContract.rewardsEarned(user1), 0 ether);
        assertEq(rewardCoin.balanceOf(user1), 20 ether);
    }


    function testLpMiningMultiUsersCase() public {
        stakingCoin.mint(user1, 100 ether);
        stakingCoin.mint(user2, 100 ether);
        assertEq(stakingCoin.balanceOf(user1), 100 ether);
        assertEq(stakingCoin.balanceOf(user2), 100 ether);

        hoax(user1);
        stakingCoin.approve(address(lpMiningContract), 2 ** 256 - 1);
        hoax(user2);
        stakingCoin.approve(address(lpMiningContract), 2 ** 256 - 1);



        hoax(user1);
        lpMiningContract.stake(10 ether);

        skip(10);
        assertEq(lpMiningContract.rewardsEarned(user1), 10 ether);

        hoax(user2);
        lpMiningContract.stake(10 ether);
        skip(10);
        assertEq(lpMiningContract.rewardsEarned(user2), 5 ether);
        assertEq(lpMiningContract.rewardsEarned(user1), 15 ether);

        hoax(user1);
        lpMiningContract.withdraw(5 ether);
        skip(30);
        assertEq(lpMiningContract.rewardsEarned(user1), 25 ether);
        assertEq(lpMiningContract.rewardsEarned(user2), 25 ether);

        assertEq(lpMiningContract.rewardsEarned(user2), 25 ether);
        hoax(user2);
        lpMiningContract.withdrawRewards();
        assertEq(lpMiningContract.rewardsEarned(user2), 0 ether);


    }
}
