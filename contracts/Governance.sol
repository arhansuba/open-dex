// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Governance {
    struct Proposal {
        address proposer;
        string description;
        bytes callData;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 endTime;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votingPower;
    uint256 public proposalCount;
    address public admin;

    event ProposalCreated(uint256 indexed proposalId, string description, address proposer);
    event Voted(uint256 indexed proposalId, bool voteFor, address voter, uint256 votingPower);
    event ProposalExecuted(uint256 indexed proposalId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createProposal(string memory description, bytes memory callData) external {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            proposer: msg.sender,
            description: description,
            callData: callData,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            endTime: block.timestamp + 7 days
        });
        emit ProposalCreated(proposalCount, description, msg.sender);
    }

    function vote(uint256 proposalId, bool voteFor) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.endTime, "Voting period over");
        require(votingPower[msg.sender] > 0, "No voting power");

        uint256 votes = votingPower[msg.sender];
        if (voteFor) {
            proposal.votesFor += votes;
        } else {
            proposal.votesAgainst += votes;
        }

        emit Voted(proposalId, voteFor, msg.sender, votes);
    }

    function executeProposal(uint256 proposalId) external onlyAdmin {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal rejected");

        (bool success,) = address(this).call(proposal.callData);
        require(success, "Execution failed");
        proposal.executed = true;

        emit ProposalExecuted(proposalId);
    }

    function allocateVotingPower(address user, uint256 amount) external onlyAdmin {
        votingPower[user] += amount;
    }
}
