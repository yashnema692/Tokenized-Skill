// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SkillTree {
    IERC20 public skillToken; // Token used for progression
    address public owner;

    struct Skill {
        string name;
        uint256 cost;  // Tokens required to unlock this skill
        bool unlocked;
    }

    mapping(address => uint256) public userProgress; // Tracks how many skills a user has unlocked
    Skill[] public skills; // List of skills in the skill tree

    event SkillUnlocked(address indexed user, uint256 skillId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    constructor(address _skillToken) {
        skillToken = IERC20(_skillToken);
        owner = msg.sender;
    }

    // Function to add skills to the skill tree
    function addSkill(string memory name, uint256 cost) external onlyOwner {
        skills.push(Skill(name, cost, false));
    }

    // Function to unlock a skill by spending tokens
    function unlockSkill(uint256 skillId) external {
        require(skillId < skills.length, "Invalid skill ID");
        Skill storage skill = skills[skillId];
        require(!skill.unlocked, "Skill already unlocked");
        require(skillToken.balanceOf(msg.sender) >= skill.cost, "Not enough tokens");

        // Transfer tokens from the user to the contract
        skillToken.transferFrom(msg.sender, address(this), skill.cost);
        skill.unlocked = true;
        userProgress[msg.sender] += 1;

        emit SkillUnlocked(msg.sender, skillId);
    }

    // Function to view all skills
    function getSkills() external view returns (Skill[] memory) {
        return skills;
    }

    // Function to check the user's unlocked skills
    function getUserProgress(address user) external view returns (uint256) {
        return userProgress[user];
    }
}
