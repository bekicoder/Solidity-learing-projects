// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract test {
    uint count = 1;
    function increment() external {
        count++;
    }
    function getCount() external view returns(uint256){
        return count;
    }
}
