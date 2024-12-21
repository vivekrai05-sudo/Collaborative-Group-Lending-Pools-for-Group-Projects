// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CollaborativeGroupLending {
    struct Project {
        string name;
        string description;
        address[] members;
        uint256 funds;
        bool completed;
    }
    
    uint256 public projectCount;
    mapping(uint256 => Project) public projects;
    mapping(address => uint256) public memberFunds;
    
    event ProjectCreated(uint256 projectId, string name, address creator);
    event FundsAdded(uint256 projectId, address member, uint256 amount);
    event ProjectCompleted(uint256 projectId);

    function createProject(string memory _name, string memory _description, address[] memory _members) public {
        projectCount++;
        projects[projectCount] = Project(_name, _description, _members, 0, false);
        emit ProjectCreated(projectCount, _name, msg.sender);
    }

    function contributeToProject(uint256 _projectId) public payable {
        Project storage project = projects[_projectId];
        require(!project.completed, "Project already completed");
        project.funds += msg.value;
        memberFunds[msg.sender] += msg.value;
        emit FundsAdded(_projectId, msg.sender, msg.value);
    }
    
    function completeProject(uint256 _projectId) public {
        Project storage project = projects[_projectId];
        require(!project.completed, "Project already completed");
        project.completed = true;
        // Assuming funds are distributed to project members equally
        uint256 share = project.funds / project.members.length;
        for (uint256 i = 0; i < project.members.length; i++) {
            payable(project.members[i]).transfer(share);
        }
        emit ProjectCompleted(_projectId);
    }
    
    function withdrawFunds(uint256 _amount) public {
        require(memberFunds[msg.sender] >= _amount, "Insufficient funds");
        payable(msg.sender).transfer(_amount);
        memberFunds[msg.sender] -= _amount;
    }
}
