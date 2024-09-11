// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address payable creator;
        uint goal;
        uint deadline;
        uint totalContributions;
        bool finalized;
    }

    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public contributions;
    uint public campaignCount;

    event CampaignCreated(uint campaignId, address creator, uint goal, uint deadline);
    event ContributionMade(uint campaignId, address contributor, uint amount);
    event FundsReleased(uint campaignId, address creator, uint totalAmount);
    event RefundIssued(uint campaignId, address contributor, uint amount);

    function createCampaign(uint _goal, uint _durationInDays) external {
        require(_goal > 0, "Goal must be greater than 0");
        campaignCount++;
        uint _deadline = block.timestamp + (_durationInDays * 1 days);

        campaigns[campaignCount] = Campaign({
            creator: payable(msg.sender),
            goal: _goal,
            deadline: _deadline,
            totalContributions: 0,
            finalized: false
        });

        emit CampaignCreated(campaignCount, msg.sender, _goal, _deadline);
    }

    function contribute(uint _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than 0");

        campaign.totalContributions += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;

        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    function finalizeCampaign(uint _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign has not ended");
        require(!campaign.finalized, "Campaign already finalized");

        if (campaign.totalContributions >= campaign.goal) {
            campaign.finalized = true;
            campaign.creator.transfer(campaign.totalContributions);
            emit FundsReleased(_campaignId, campaign.creator, campaign.totalContributions);
        } else {
            campaign.finalized = true;
        }
    }

    function withdraw(uint _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign has not ended");
        require(campaign.totalContributions < campaign.goal, "Goal was met, no refunds available");
        require(campaign.finalized, "Campaign must be finalized");

        uint contribution = contributions[_campaignId][msg.sender];
        require(contribution > 0, "No contributions to withdraw");

        contributions[_campaignId][msg.sender] = 0;
        payable(msg.sender).transfer(contribution);

        emit RefundIssued(_campaignId, msg.sender, contribution);
    }
}
