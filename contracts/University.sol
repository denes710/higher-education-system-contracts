// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IUniversity.sol";

import "./Library/Common.sol";
import "./CourseCatalog.sol";
import "./Degree.sol";
import "./Person.sol";
import "./Semester.sol";
import "./Student.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract University is Ownable, IUniversity {
    using Counters for Counters.Counter;
    using Common for Common.State;

    // current ongoing semester id
    Counters.Counter public semesterId;
    // current state of the university
    Common.State public currentState;
    // semester id - semester contract
    mapping(uint256 => Semester) public semesters;

    // smart contract for tracking teachers
    Person public teacher;
    // smart contract for tracking students
    Student public student;
    // smart contract for tracking minted degrees
    Degree public degree;
    // smart contract for tracking available courses at university
    CourseCatalog public courseCatalog;

    constructor() {
        teacher = new Person("Teacher", "tch");
        student = new Student("Student", "std");
        courseCatalog = new CourseCatalog("CourseCatalog", "coc", address(this));
        degree = new Degree("Degree", "deg");
        currentState.init();
    }

    // Teacher
    function createTeacher(address to_) onlyOwner inOffSeason public {
        teacher.mint(to_);
    }

    function addMyCourseNextSemester(
        uint256 courseId_,
        uint8 numberOfStudents_
    ) onlyTeacher inPlanning public {
        require(courseCatalog.ownerOf(courseId_) == _msgSender(), "You do not own this token!");
        semesters[semesterId.current()].addNewCourse(courseId_, numberOfStudents_);
    }

    function markStudent(uint256 tokenId_, uint8 mark_) onlyTeacher inActice public {
        require(courseCatalog.ownerOf(semesters[semesterId.current()].courseIds(tokenId_)) == _msgSender(),
            "You are not the owner of the course!");
        semesters[semesterId.current()].markStudent(tokenId_, mark_);
        student.addMark(mark_, courseCatalog.creditValues(tokenId_),
            semesters[semesterId.current()].studentIds(tokenId_));
    }

    // Student
    function createStudent(address to_) onlyOwner inOffSeason public {
        student.mint(to_);
    }

    function mintDegree(uint256 tokenId_) onlyStudent inOffSeason public {
        require(student.ownerOf(tokenId_) == _msgSender(), "Sender does not own the token!");
        (uint16 sumCredits, uint16 sumMarks,) = student.students(tokenId_);
        require(sumCredits >= 180, "You do not have enough credits!");
        degree.mint(_msgSender(), sumMarks, sumCredits);
    }

    function setHashDegree(uint256 tokenId_, uint32 hash_) onlyOwner inOffSeason public {
        require(degree.ownerOf(tokenId_) != address(0), "Token ID is not minted yet!");
        require(degree.hashValues(tokenId_) == 0, "Hash is already set!");
        degree.setHash(tokenId_, hash_);
    }

    function applyForCourse(uint256 courseId_, uint256 studentId_) onlyStudent inApplying public {
        require(student.ownerOf(studentId_) == _msgSender(), "You are not the owner this id!");
        (uint16 sumcredits, uint16 sumMarks,) = student.students(studentId_);
        semesters[semesterId.current()].applyForCourse(courseId_, studentId_, sumMarks * sumcredits);
    }

    // Semester
    function createNewSemester() onlyOwner inOffSeason public {
        require(currentState.current() == Common.EState.offSeason);
        semesterId.increment();
        // TODO perhaps semester id used in the contract name
        semesters[semesterId.current()] = new Semester("Semester", "sem", address(this), semesterId.current());
        currentState.nextState();
    }

    function setNextState() onlyOwner public {
        semesters[semesterId.current()].setNextState();
        currentState.nextState();
    }

    modifier onlyTeacher() {
        require(teacher.balanceOf(_msgSender()) == 1, "You must be teacher!");
        _;
    }

    modifier onlyStudent() {
        require(student.balanceOf(_msgSender()) == 1, "You must be a student!");
        _;
    }

    modifier inOffSeason() {
        require(currentState.current() == Common.EState.offSeason, "This is not the off season state!");
        _;
    }

    modifier inPlanning() {
        require(currentState.current() == Common.EState.planning, "This is not the planning state!");
        _;
    }

    modifier inApplying() {
        require(currentState.current() == Common.EState.applying, "This is not the applying state!");
        _;
    }

    modifier inTrading() {
        require(currentState.current() == Common.EState.trading, "This is not the trading state!");
        _;
    }

    modifier inActice() {
        require(currentState.current() == Common.EState.active, "This is not the active state!");
        _;
    }
}