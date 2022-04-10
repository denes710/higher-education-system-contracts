// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ISemester.sol";

import "./Library/Common.sol";
import "./Library/CourseHelper.sol";
import "./University.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Semester is Ownable, ISemester, ERC721 {
    using Counters for Counters.Counter;
    using CourseHelper for CourseHelper.Course;
    using Common for Common.State;

    // current state of the semester
    Common.State public currentState;
    // given unique id for semester
    uint256 public semesterId;
    // tokenid - mark
    mapping(uint256 => uint8) public marks;
    // tokenid - student id
    mapping(uint256 => uint256) public studentIds;
    // tokenid - course id
    mapping(uint256 => uint256) public courseIds;
    // course id - price
    mapping(uint256 => uint256) public prices;

    // main university smart contract
    University private _university;
    // last course space unique id
    Counters.Counter private _tokenId;
    // course id - course helper
    mapping(uint256 => CourseHelper.Course) private _courses;

    constructor(
        string memory name_,
        string memory symbol_,
        address uniAddr_,
        uint256 semesterId_) ERC721(name_, symbol_) {
        _university = University(uniAddr_);
        currentState.state = Common.EState.planning;
        semesterId = semesterId_;
    }

    function addNewCourse(uint256 courseId_, uint16 numberOfStudents_, uint256 price_) onlyOwner inPlanning public {
        require(_courses[courseId_].created == false, "This course is already added!");
        _courses[courseId_].created = true;
        _courses[courseId_].limit = numberOfStudents_;
        prices[courseId_] = price_;
        emit AddNewCourse(courseId_, numberOfStudents_, price_);
    }

    function setNextState() onlyOwner public {
        require(currentState.current() != Common.EState.offSeason, "This semester has been already end!");
        currentState.nextState();
        emit SetNextState(uint8(currentState.current()));
    }

    function markStudent(uint256 tokenId_, uint8 mark_) onlyOwner inActice public {
        require(super.ownerOf(tokenId_) != address(0), "This token is not exist!");
        marks[tokenId_] = mark_;
        emit StudentMarked(tokenId_, mark_);
    }

    function applyForCourse(uint256 courseId_, uint256 studentId_, uint256 index_) onlyOwner inApplying public {
        require(_courses[courseId_].created == true, "There is no course with given id!");
        (bool isRemoved, uint256 removedStudentId) = _courses[courseId_].applyForCourse(studentId_,
            (index_ + 1) * 1000 / 30  + _courses[courseId_].limit - _courses[courseId_].numberOfStudents.current());
        emit ApplyForCourse(courseId_, studentId_,  _courses[courseId_].keys[studentId_]);
        if (isRemoved) {
            emit RemoveForCourse(courseId_, removedStudentId);
        }
    }

    function claim(uint256 courseId_, uint256 studentId_) onlyStudent inTrading public {
        require(_university.student().ownerOf(studentId_) == _msgSender(),
            "You are not the owner of this student token!");
        require(_courses[courseId_].created, "There is no course with this id!");
        require(_courses[courseId_].claims[studentId_] == false, "You have already claimed this course!");
        require(_courses[courseId_].keys[studentId_] != 0, "You have no place in this course!");

        _tokenId.increment();
        super._mint(_msgSender(), _tokenId.current());
        studentIds[_tokenId.current()] = studentId_;
        courseIds[_tokenId.current()] = courseId_;
        _courses[courseId_].claims[studentId_] = true;
        emit ClaimCourse(courseId_, studentId_, _tokenId.current());
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) onlyOwner inTrading public virtual override {
        super.transferFrom(from_, to_, tokenId_);
        updateStudentId(from_, to_, tokenId_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) onlyOwner inTrading public virtual override {
        super.safeTransferFrom(from_, to_, tokenId_);
        updateStudentId(from_, to_, tokenId_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes memory data_
    ) onlyOwner inTrading public virtual override {
        super.safeTransferFrom(from_, to_, tokenId_, data_);
        updateStudentId(from_, to_, tokenId_);
    }

    function updateStudentId(address from_, address to_, uint256 tokenId_) internal {
        if (from_ == owner()) {
            studentIds[tokenId_] = _university.student().tokenOf(to_);
        } else {
            studentIds[tokenId_] = 0;
        }
    }

    modifier inPlanning() {
        require(currentState.current() == Common.EState.planning, "This is not the planning state!");
        _;
    }

    modifier inTrading() {
        require(currentState.current() == Common.EState.trading, "This is not the trading state!");
        _;
    }

    modifier inApplying() {
        require(currentState.current() == Common.EState.applying, "This is not the applying state!");
        _;
    }

    modifier inActice() {
        require(currentState.current() == Common.EState.active, "This is not the active state!");
        _;
    }

    modifier onlyTeacher() {
        require(_university.teacher().balanceOf(_msgSender()) == 1, "You must be a teacher!");
        _;
    }

    modifier onlyStudent() {
        require(_university.student().balanceOf(_msgSender()) == 1, "You must be a student!");
        _;
    }
}