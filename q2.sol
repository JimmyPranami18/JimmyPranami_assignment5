// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Proposal {
        string description;
        uint voteCount;
        bool exists;
    }

    mapping(uint => Proposal) public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;
    uint public proposalCount;

    event ProposalCreated(uint proposalId, string description);
    event VoteCasted(uint proposalId, address voter);

    function createProposal(string memory _description) external {
        require(bytes(_description).length > 0, "Proposal description cannot be empty");
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: _description,
            voteCount: 0,
            exists: true
        });

        emit ProposalCreated(proposalCount, _description);
    }

    function vote(uint _proposalId) external {
        require(proposals[_proposalId].exists, "Proposal does not exist");
        require(!hasVoted[_proposalId][msg.sender], "You have already voted");

        proposals[_proposalId].voteCount++;
        hasVoted[_proposalId][msg.sender] = true;

        emit VoteCasted(_proposalId, msg.sender);
    }

    function getWinningProposal() external view returns (uint winningProposalId) {
        uint highestVoteCount = 0;

        for (uint i = 1; i <= proposalCount; i++) {
            if (proposals[i].voteCount > highestVoteCount) {
                highestVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
    }

    function getProposalDescription(uint _proposalId) external view returns (string memory) {
        require(proposals[_proposalId].exists, "Proposal does not exist");
        return proposals[_proposalId].description;
    }
}
