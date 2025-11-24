// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MysteryNFT is ERC721 {
    uint256 private _tokenIds;

    constructor() ERC721("MysteryNFT", "MNFT") {}

    // ai cũng có thể mint
    function mintNFT(address to) public returns (uint256) {
        _tokenIds += 1;
        uint256 newId = _tokenIds;
        _mint(to, newId);
        return newId;
    }
}
