// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStaking {

    uint256 public rewardRate = 1; // 1 token per second
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public totalStaked;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    constructor() {
        lastUpdateTime = block.timestamp;
    }
    // 1️⃣ Update global reward
    function updateReward(address account) internal {

        // calculate new rewardPerToken
        if (totalStaked > 0) {
            uint256 timePassed = block.timestamp - lastUpdateTime;

            rewardPerTokenStored =
                rewardPerTokenStored +
                (timePassed * rewardRate) / totalStaked;
        }

        lastUpdateTime = block.timestamp;

        // update user reward
        if (account != address(0)) {
            rewards[account] =
                rewards[account] +
                balanceOf[account] *
                (rewardPerTokenStored - userRewardPerTokenPaid[account]);

            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    function stake(uint256 amount) external {
        updateReward(msg.sender);

        totalStaked += amount;
        balanceOf[msg.sender] += amount;
    }

    function claim() external {
        updateReward(msg.sender);

        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        // here we would transfer reward token
    }
}
