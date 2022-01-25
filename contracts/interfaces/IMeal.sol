// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IMeal {
    function getMealsBySummoner(uint256 summonerId) external view returns (uint[] memory);
}