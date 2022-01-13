// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IMeal {
    function getMealsBySummoner(uint256 summonerId) external view returns (uint[] memory);
}