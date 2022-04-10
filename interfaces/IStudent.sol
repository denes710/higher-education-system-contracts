// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of a Student compliant contract.
 */
interface IStudent {
    /// @dev Emitted when `tokenId` token is gotten a new `mark` with a `credit` value.
    event Marked(
        uint256 indexed tokenId,
        uint8 indexed mark,
        uint8 indexed credit
    );
}