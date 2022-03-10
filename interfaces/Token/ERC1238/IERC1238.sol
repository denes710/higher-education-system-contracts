// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1238 compliant contract.
 */
interface IERC1238 is IERC165 {
    // @dev Emitted when `tokenId` token is minted to `to`, an address.
    event Minted(
        address indexed to,
        uint256 indexed tokenId
    );

    // @dev Emitted when `tokenId` token is burned.
    event Burned(
        address indexed owner,
        uint256 indexed tokenId
    );

    // @dev Returns the ID of the token owned by `owner`, if it owns one, and 0 otherwise
    function balanceOf(address owner) external view returns (uint256);

    // @dev Returns the owner of the `tokenId` token.
    function ownerOf(uint256 tokenId) external view returns (address);
}