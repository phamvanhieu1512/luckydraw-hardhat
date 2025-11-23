// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RewardToken.sol";
import "./MysteryNFT.sol";

contract LuckyDraw {
    RewardToken public token;
    MysteryNFT public nft;

    uint256 public boxPrice = 0.1 ether;  // tên rõ ràng
    address public owner;

    event SpinResult(
        address indexed user,
        string rewardType,
        uint256 amount,
        uint256 nftId,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address tokenAddr, address nftAddr) {
        token = RewardToken(tokenAddr);
        nft = MysteryNFT(nftAddr);
        owner = msg.sender;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        boxPrice = newPrice;
    }

    function getPrice() external view returns (uint256) {
        return boxPrice;
    }

    function spin() external payable {
        require(msg.value == boxPrice, "invalid price");

        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    block.timestamp,
                    block.prevrandao,
                    block.number
                )
            )
        ) % 100;

        if (random < 50) {
            emit SpinResult(msg.sender, "none", 0, 0, block.timestamp);
        } 
        else if (random < 80) {
            uint256 amount = 5 * 1e18;
            token.mint(msg.sender, amount);
            emit SpinResult(msg.sender, "token", amount, 0, block.timestamp);
        } 
        else {
            uint256 nftId = nft.mintNFT(msg.sender);
            emit SpinResult(msg.sender, "nft", 0, nftId, block.timestamp);
        }
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
