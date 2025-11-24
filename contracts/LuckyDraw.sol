// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RewardToken.sol";
import "./MysteryNFT.sol";

contract LuckyDraw {
    RewardToken public token;
    MysteryNFT public nft;

    uint256 public boxPrice = 0.1 ether;

    struct SpinInfo {
        string rewardType;
        uint256 amount;
        uint256 nftId;
        uint256 timestamp;
    }

    mapping(address => SpinInfo[]) public userSpins;
    address[] public allUsers;

    event SpinResult(
        address indexed user,
        string rewardType,
        uint256 amount,
        uint256 nftId,
        uint256 timestamp
    );

    constructor(address tokenAddr, address nftAddr) {
        token = RewardToken(tokenAddr);
        nft = MysteryNFT(nftAddr);
    }

    function setPrice(uint256 newPrice) public {
        boxPrice = newPrice;
    }

    function getPrice() public view returns (uint256) {
        return boxPrice;
    }

    function spin() public payable {
        require(msg.value >= boxPrice, "insufficient payment");

        if (userSpins[msg.sender].length == 0) {
            allUsers.push(msg.sender);
        }

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

        if (random < 40) {
            emit SpinResult(msg.sender, "none", 0, 0, block.timestamp);
            userSpins[msg.sender].push(SpinInfo("none", 0, 0, block.timestamp));
        } else if (random < 70) {
            uint256 amount = 5 * 1e18;
            token.mint(msg.sender, amount);
            emit SpinResult(msg.sender, "token", amount, 0, block.timestamp);
            userSpins[msg.sender].push(
                SpinInfo("token", amount, 0, block.timestamp)
            );
        } else {
            uint256 nftId = nft.mintNFT(msg.sender);
            emit SpinResult(msg.sender, "nft", 0, nftId, block.timestamp);
            userSpins[msg.sender].push(
                SpinInfo("nft", 0, nftId, block.timestamp)
            );
        }
    }

    function getUserSpins(
        address user
    ) external view returns (SpinInfo[] memory) {
        return userSpins[user];
    }

    function getAllSpins()
        public
        view
        returns (address[] memory, SpinInfo[][] memory)
    {
        SpinInfo[][] memory spins = new SpinInfo[][](allUsers.length);
        for (uint256 i = 0; i < allUsers.length; i++) {
            spins[i] = userSpins[allUsers[i]];
        }
        return (allUsers, spins);
    }

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}
