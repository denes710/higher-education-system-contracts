// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of a Semester compliant contract.
 */
interface ISemester {
    /// @dev Emitted when `tokenId` token is minted with `creditValue`.
    event AddNewCourse(
        uint256 indexed courseId,
        uint16 indexed numberOfStudents
    );

    /// @dev Emitted when semester sets a `newState`.
    event SetNextState(
        uint8 indexed newState
    );

    /// @dev Emitted when `tokenId` token is marked with `mark`.
    event StudentMarked(
        uint256 indexed tokenId,
        uint8 indexed mark
    );

    /// @dev Emitted when the owner of `studentId` token successfully applies for `courseId` with `index`.
    event ApplyForCourse(
        uint256 indexed courseId,
        uint256 indexed studentId,
        uint256 indexed index
    );

    /// @dev Emitted when the owner of `studentId` token is removed from `courseId` course.
    event RemoveForCourse(
        uint256 indexed courseId,
        uint256 indexed studentId
    );

    /// @dev Emitted when `tokenId` token is minted with the owner of `studentId` token in the `courseId` course.
    event ClaimCourse(
        uint256 indexed courseId,
        uint256 indexed studentId,
        uint256 indexed tokenId
    );
}