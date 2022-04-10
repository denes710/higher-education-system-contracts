// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC1238.sol";

/**
 * @dev Required interface of an ERC1238Metadata compliant contract.
 */
interface IERC1238Metadata is IERC1238 {
    /// @dev Emitted when the URI of `tokenId` token is set to `uri`.
    event TokenURISet(
        uint256 indexed tokenId,
        string indexed uri
    );

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