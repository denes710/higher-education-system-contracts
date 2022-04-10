// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OrderedList.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @dev Implementation of a helper struct for keeping up-to-date course students.
 *
 * It consists of a binary tree that is ordered by students' index.
 * The limit is the maximum number of students in a given course.
 */
library CourseHelper {
    using OrderedList for OrderedList.Tree;
    using Counters for Counters.Counter;

    struct Course {
        bool created;
        uint16 limit;
        OrderedList.Tree tree;
        // credit index - student id
        mapping(uint => uint256) values;
        // student id - is claimed
        mapping(uint256 => bool) claims;
        // student id - credit index
        mapping(uint256 => uint) keys;
        Counters.Counter numberOfStudents;
    }

    function applyForCourse(Course storage self, uint256 student, uint index) public returns (bool, uint256) {
        require(self.keys[student] == 0, "Student has already applied for this course!");
        require(index > 1, "Student has too low index!");

        if (self.limit <= self.numberOfStudents.current()) {
            uint firstIndex = self.tree.first();
            require(firstIndex < index, "The first index is too high to apply for this course!");
            uint256 removedStudentId = self.values[firstIndex];
            _remove(self, firstIndex);
            if (self.tree.exists(index)) {
                _insert(self, index - 1, student); // FIXME better handling is necessary
            } else {
                _insert(self, index, student);
            }
            return (true, removedStudentId);
        }

        if (self.tree.exists(index)) {
            _insert(self, index - 1, student); // FIXME better handling is necessary
        } else {
            _insert(self, index, student);
        }
        return (false, 0);
    }

    function leaveFromCourse(Course storage self, uint256 student) public {
        require(self.keys[student] != 0);
        _remove(self, self.keys[student]);
    }

    function first(Course storage self) public view returns (uint) {
        return self.tree.first();
    }

    function last(Course storage self) public view returns (uint) {
        return self.tree.last();
    }

    function next(Course storage self, uint key) public view returns (uint) {
        return self.tree.next(key);
    }

    function _insert(Course storage self, uint _key, uint256 _student) private {
        self.tree.insert(_key);
        self.values[_key] = _student;
        self.keys[_student] = _key;
        self.numberOfStudents.increment();
    }

    function _remove(Course storage self, uint _key) private {
        self.tree.remove(_key);
        delete self.keys[self.values[_key]];
        delete self.values[_key];
        self.numberOfStudents.decrement();
    }
}