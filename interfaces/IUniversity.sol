// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an University compliant contract.
 */
interface IUniversity {
    /// @dev Emitted when `tokenId` token is listed with `price` by the owner of `studentId` token in `semesterId` semester.
    event CourseListing(
        uint256 indexed semesterId,
        uint256 indexed tokenId,
        uint256 indexed studentId,
        uint256 price
    );

    /// @dev Emitted when `tokenId` token is unlisted by the owner of `studentId` token in `semesterId` semester.
    event CancelListing(
        uint256 indexed semesterId,
        uint256 indexed tokenId,
        uint256 indexed studentId
    );
}