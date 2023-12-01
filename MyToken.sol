// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract NFTCommentReward is Ownable {
    // Struct to store NFT information
    struct NFTInfo {
        string name;
        string metadataURI;
    }

    // Mapping from NFT token ID to NFT information
    mapping(uint256 => NFTInfo) public nftInfo;

    // Mapping from NFT token ID to user comments
    mapping(uint256 => mapping(address => string)) public comments;

    // ERC20 token used for rewards
    IERC20 public rewardToken;

    // Event emitted when a user adds a comment
    event CommentAdded(address indexed user, uint256 indexed tokenId, string comment);

    // Event emitted when a user receives a reward
    event RewardSent(address indexed user, uint256 amount);

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    // Function to add NFT information
    function addNFTInfo(uint256 _tokenId, string memory _name, string memory _metadataURI) external onlyOwner {
        nftInfo[_tokenId] = NFTInfo(_name, _metadataURI);
    }

    // Function to allow users to comment on NFTs and receive rewards
    function addComment(uint256 _tokenId, string memory _comment) external {
        require(bytes(_comment).length > 0, "Comment should not be empty");
        require(rewardToken.balanceOf(address(this)) > 0, "No rewards available");

        // Add the comment
        comments[_tokenId][msg.sender] = _comment;

        // Send reward to the user
        uint256 rewardAmount = 1; // Adjust the reward amount as needed
        rewardToken.transfer(msg.sender, rewardAmount);

        // Emit events
        emit CommentAdded(msg.sender, _tokenId, _comment);
        emit RewardSent(msg.sender, rewardAmount);
    }

    // Function to retrieve the number of rewards available in the contract
    function getAvailableRewards() external view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }
}