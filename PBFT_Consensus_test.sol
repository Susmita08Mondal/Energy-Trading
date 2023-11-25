// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PBFTCoordination {
    enum Phase { SecretUploading, PrePrepare, Prepare, Commit, Reply }

    struct Delegate {
        bool isLeader;
        bool isFollower;
        bool committed;
        bool convergenceAchieved;
    }

    mapping(address => Delegate) public delegates;
    mapping(address => string) public messages;  
    mapping(string => uint) public messageCounts; 
    address[] public delegateAddresses;

    event PrePrepareSent(address indexed sender, string message);
    event PrepareSent(address indexed sender, string message);
    event CommitSent(address indexed sender, string message);
    event ReplyReceived(address indexed sender, string message);

    function registerDelegate(address delegateAddress, uint iterationNumber) public {
        require(!delegates[delegateAddress].isLeader && !delegates[delegateAddress].isFollower, "Delegate already registered");
      
        bool isLeader = iterationNumber % delegateAddresses.length == getIndex(delegateAddress);
        
        delegates[delegateAddress] = Delegate(isLeader, !isLeader, false, false);
        delegateAddresses.push(delegateAddress);
    }

    function secretUploadingPhase(string memory message) public {
        messages[msg.sender] = message;
        messageCounts[message]++;
    }

    function prePreparePhase(string memory message) public {
        require(delegates[msg.sender].isLeader, "Only leader can initiate Pre-Prepare phase");
        require(messageCounts[message] >= (delegateAddresses.length - faultTolerance()), "Not enough messages");
        emit PrePrepareSent(msg.sender, message);
    }

    function preparePhase(string memory message) public {
        require(delegates[msg.sender].isFollower, "Only followers can participate in Prepare phase");
        require(messageCounts[message] >= (delegateAddresses.length - faultTolerance()), "Not enough messages");
        if (countHelloWorldMessages("MPreparekn") > 3 * faultTolerance()) {
            emit PrepareSent(msg.sender, message);
        }
    }

    function commitPhase(string memory message) public {
        require(delegates[msg.sender].isFollower, "Only followers can participate in Commit phase");
        if (countHelloWorldMessages("MCommitkn") > 3 * faultTolerance()) {
            emit CommitSent(msg.sender, message);
        }
    }

    function replyPhase(string memory message) public {
        require(delegates[msg.sender].isFollower, "Only followers can participate in Reply phase");
        emit ReplyReceived(msg.sender, message);
    }
    function getIndex(address delegateAddress) internal view returns (uint) {
        for (uint i = 0; i < delegateAddresses.length; i++) {
            if (delegateAddresses[i] == delegateAddress) {
                return i;
            }
        }
        revert("Delegate not found");
    }
    function countHelloWorldMessages(string memory messageType) internal view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < delegateAddresses.length; i++) {
            address delegateAddress = delegateAddresses[i];
            string memory message = messages[delegateAddress];
            if (keccak256(abi.encodePacked(message)) == keccak256(abi.encodePacked("Hello world"))) {
                if (keccak256(abi.encodePacked(messageType)) == keccak256(abi.encodePacked("MPreparekn")) ||
                    keccak256(abi.encodePacked(messageType)) == keccak256(abi.encodePacked("MCommitnk"))) {
                    count++;
                }
            }
        }
        return count;
    }
    
    function faultTolerance() internal pure returns (uint) {
        return 2;
    }
}
