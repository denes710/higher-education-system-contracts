// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IStudent.sol";

import "./Person.sol";

contract Student is Person, IStudent {
    using Counters for Counters.Counter;

    struct StudentInfo {
        uint16 sumCredits;
        uint16 sumMarks;
        bool hasValue;
    }

    // study information of students
    mapping(uint256 => StudentInfo) public students;

    constructor(string memory name_, string memory symbol_) Person(name_, symbol_) {}

    function mint(address to_) onlyOwner override public {
        super.mint(to_);
        students[_tokenId.current()].hasValue = true;
    }

    function addMark(uint8 mark_, uint8 credit_, uint256 tokenId_) onlyOwner public {
        require(students[tokenId_].hasValue, "There is no student with this id!");
        students[tokenId_].sumCredits += credit_;
        students[tokenId_].sumMarks += mark_;
        emit Marked(tokenId_, mark_, credit_);
    }
}