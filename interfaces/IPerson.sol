// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of a Person compliant contract.
 */
interface IPerson {
    /// @dev Returns the ID of the token owned by `owner`, if it owns one, and 0 otherwise
    function tokenOf(address owner) external view returns (uint256);
}