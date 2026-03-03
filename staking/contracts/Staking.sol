// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "hardhat/console.sol";

/// @notice Minimal ERC20 interface (gas efficient)
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @notice Reward calculation library
library RewardMath {
    uint256 internal constant PRECISION = 1e18;

    function rewardPerToken(
        uint256 rewardRate,
        uint256 lastUpdateTime,
        uint256 totalStaked,
        uint256 storedRewardPerToken
    ) internal view returns (uint256) {
        if (totalStaked == 0) return storedRewardPerToken;

        unchecked {
            return storedRewardPerToken +
                ((block.timestamp - lastUpdateTime) *
                    rewardRate *
                    PRECISION) /
                totalStaked;
        }
    }

    function earned(
        uint256 userBalance,
        uint256 rewardPerTokenStored,
        uint256 userRewardPerTokenPaid,
        uint256 rewards
    ) internal pure returns (uint256) {
        unchecked {
            return
                (userBalance *
                    (rewardPerTokenStored - userRewardPerTokenPaid)) /
                PRECISION +
                rewards;
        }
    }
}

contract Staking is ReentrancyGuard {
    using RewardMath for uint256;

    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/

    error ZeroAmount();
    error TransferFailed();
    error NoRewards();

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    uint256 public immutable rewardRate; // tokens per second

    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public totalStaked;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL UPDATE   
    //////////////////////////////////////////////////////////////*/

    function _updateReward(address account) internal {
        rewardPerTokenStored = RewardMath.rewardPerToken(
            rewardRate,
            lastUpdateTime,
            totalStaked,
            rewardPerTokenStored
        );

        lastUpdateTime = block.timestamp;

        if (account != address(0)) {
            rewards[account] = RewardMath.earned(
                balanceOf[account],
                rewardPerTokenStored,
                userRewardPerTokenPaid[account],
                rewards[account]
            );

            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    /*//////////////////////////////////////////////////////////////
                               STAKE
    //////////////////////////////////////////////////////////////*/

    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        _updateReward(msg.sender);

        totalStaked += amount;
        balanceOf[msg.sender] += amount;

        bool success = stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (!success) revert TransferFailed();
    }

    /*//////////////////////////////////////////////////////////////
                               WITHDRAW
    //////////////////////////////////////////////////////////////*/

    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        _updateReward(msg.sender);

        totalStaked -= amount;
        balanceOf[msg.sender] -= amount;

        bool success = stakingToken.transfer(msg.sender, amount);
        if (!success) revert TransferFailed();
    }

    /*//////////////////////////////////////////////////////////////
                               CLAIM
    //////////////////////////////////////////////////////////////*/

    function claim() external nonReentrant {
        _updateReward(msg.sender);

        uint256 reward = rewards[msg.sender];
        if (reward == 0) revert NoRewards();

        rewards[msg.sender] = 0;

        bool success = rewardToken.transfer(msg.sender, reward);
        if (!success) revert TransferFailed();
    }

    /*//////////////////////////////////////////////////////////////
                              VIEW
    //////////////////////////////////////////////////////////////*/

    function earned(address account) external view returns (uint256) {
        uint256 currentRewardPerToken = RewardMath.rewardPerToken(
            rewardRate,
            lastUpdateTime,
            totalStaked,
            rewardPerTokenStored
        );

        return
            RewardMath.earned(
                balanceOf[account],
                currentRewardPerToken,
                userRewardPerTokenPaid[account],
                rewards[account]
            );
    }
}
