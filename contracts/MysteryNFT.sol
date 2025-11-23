// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MysteryNFT is ERC721, Ownable {
    uint256 private currentId;

    constructor() 
        ERC721("LuckyNFT", "LNFT") 
        Ownable(msg.sender) 
    {}

    function mintNFT(address to) external onlyOwner returns (uint256) {
        currentId++;
        _mint(to, currentId);
        return currentId;
    }
}
