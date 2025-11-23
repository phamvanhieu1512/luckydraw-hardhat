// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RewardToken.sol";
import "./MysteryNFT.sol";

contract LuckyDraw {
    RewardToken public token;
    MysteryNFT public nft;

    uint256 public boxPrice = 0.1 ether;
    address public owner;

    struct SpinInfo {
        string rewardType;
        uint256 amount;
        uint256 nftId;
        uint256 timestamp;
    }

    mapping(address => SpinInfo[]) public userSpins;
    address[] public allUsers; // danh sách người chơi

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

    function getPrice() public view returns (uint256) {
        return boxPrice;
    }

    function spin() public payable {
        require(msg.value == boxPrice, "invalid price");

        // Lưu user nếu lần đầu spin
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

        if (random < 30) {
            // 30% none
            emit SpinResult(msg.sender, "none", 0, 0, block.timestamp);
            userSpins[msg.sender].push(SpinInfo("none", 0, 0, block.timestamp));
        } else if (random < 80) {
            // 50% token (30–79)
            uint256 amount = 5 * 1e18;
            token.mint(msg.sender, amount);
            emit SpinResult(msg.sender, "token", amount, 0, block.timestamp);
            userSpins[msg.sender].push(
                SpinInfo("token", amount, 0, block.timestamp)
            );
        } else {
            // 20% NFT (80–99)
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

    // Hàm mới: lấy toàn bộ lịch sử spin
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

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
