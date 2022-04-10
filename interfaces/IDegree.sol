// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of a Degree compliant contract.
 */
interface IDegree {
    /// @dev Emitted when `tokenId` token is minted with `creditValue`.
    event CreditValue(
        uint256 indexed tokenId,
        uint32 indexed creditValue
    );
}