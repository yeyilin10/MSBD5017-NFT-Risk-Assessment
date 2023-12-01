const { expect } = require('chai');
const { ethers } = require('hardhat');

const NFTCommentReward = artifacts.require('NFTCommentReward');
const MockERC20 = artifacts.require('MockERC20');

contract('NFTCommentReward', accounts => {
    const [owner, user1] = accounts;

    beforeEach(async () => {
        // Deploy a mock ERC20 token
        this.rewardToken = await MockERC20.new("RewardToken", "RT", { from: owner });

        // Deploy the NFTCommentReward contract
        this.nftCommentReward = await NFTCommentReward.new(this.rewardToken.address, { from: owner });

        // Transfer some tokens to the NFTCommentReward contract for rewards
        await this.rewardToken.transfer(this.nftCommentReward.address, 1000, { from: owner });
    });

    it('should add NFT info and allow users to comment and receive rewards', async () => {
        // Add NFT Info
        await this.nftCommentReward.addNFTInfo(1, "CryptoPunk", "metadataURI", { from: owner });

        // Add a comment
        await this.nftCommentReward.addComment(1, "Nice NFT!", { from: user1 });

        // Check that the comment was added
        const comment = await this.nftCommentReward.comments(1, user1);
        expect(comment).to.equal("Nice NFT!");

        // Check the reward
        const balance = await this.rewardToken.balanceOf(user1);
        expect(balance.toNumber()).to.equal(1);

        // Check events
        const logAddComment = await this.nftCommentReward.getPastEvents('CommentAdded', { fromBlock: 0, toBlock: 'latest' });
        expect(logAddComment[0].args.user).to.equal(user1);
        expect(logAddComment[0].args.tokenId.toNumber()).to.equal(1);
        expect(logAddComment[0].args.comment).to.equal("Nice NFT!");

        const logRewardSent = await this.nftCommentReward.getPastEvents('RewardSent', { fromBlock: 0, toBlock: 'latest' });
        expect(logRewardSent[0].args.user).to.equal(user1);
        expect(logRewardSent[0].args.amount.toNumber()).to.equal(1);
    });
});