// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Meal is ERC721Enumerable, AccessControl {

    uint tokenIds = 1;
    string public name;
    string public symbol;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(string memory _name, string memory _symbol, address extended, address _rarity) ERC721(_rarity) {
        name = _name;
        symbol = _symbol;
        _setupRole(DEFAULT_ADMIN_ROLE, extended);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function mint(uint to) external onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenIds);
        tokenIds++;
    }

    function getMealsBySummoner(uint256 summonerId) public view returns (uint[] memory) {
        uint256 arrayLength = balanceOf(summonerId);
        uint[] memory _meals = new uint[](arrayLength);
        for (uint256 i = 0; i < arrayLength; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(summonerId, i);
            _meals[i] = tokenId;
        }
        return _meals;
    }

}