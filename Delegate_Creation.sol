// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DelegateSelection {
    address public owner;
    uint256 public votingEndTime;
    
    mapping(address => uint256) public votes;
    address[] public participants;
    address[] public delegateCommittee;
    
    event Voted(address indexed voter, address indexed delegate);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier votingOpen() {
        require(block.timestamp < votingEndTime, "Voting has ended");
        _;
    }

    modifier votingClosed() {
        require(block.timestamp >= votingEndTime, "Voting is still open");
        _;
    }

    constructor(address[] memory _participants, uint256 _votingDuration) {
        owner = msg.sender;
        participants = _participants;
        votingEndTime = block.timestamp + _votingDuration;
    }

    function vote(address delegate) external votingOpen {
        require(isParticipant(msg.sender), "Not a participant");
        require(isParticipant(delegate), "Delegate is not a participant");
        require(msg.sender != delegate, "Cannot vote for yourself");

        votes[delegate]++;
        emit Voted(msg.sender, delegate);
    }

    function isParticipant(address participant) public view returns (bool) {
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == participant) {
                return true;
            }
        }
        return false;
    }

    function getDelegateCommittee(uint256 d) external onlyOwner votingClosed {
        require(d <= participants.length, "Invalid committee size");

        address[] memory sortedParticipants = sortParticipantsByVotes();
        delegateCommittee = new address[](d);

        for (uint256 i = 0; i < d; i++) {
            delegateCommittee[i] = sortedParticipants[i];
        }
    }

    function sortParticipantsByVotes() internal view returns (address[] memory) {
        address[] memory sorted = participants;

        for (uint256 i = 0; i < sorted.length - 1; i++) {
            for (uint256 j = 0; j < sorted.length - i - 1; j++) {
                if (votes[sorted[j]] < votes[sorted[j + 1]]) {
                    (sorted[j], sorted[j + 1]) = (sorted[j + 1], sorted[j]);
                }
            }
        }

        return sorted;
    }
}
