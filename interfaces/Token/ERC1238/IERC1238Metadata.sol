// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC1238.sol";

/**
 * @title ERC-1238 TODO Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721 TODO
 */
interface IERC1238Metadata is IERC1238 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}