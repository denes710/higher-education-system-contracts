// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../interfaces/Token/ERC1238/IERC1238.sol";
import "../../../interfaces/Token/ERC1238/IERC1238Metadata.sol";

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract ERC1238 is Context, ERC165, IERC1238, IERC1238Metadata {
    using Address for address;
    using Strings for uint256;

    // Badge's name
    string private _name;

    // Badge's symbol
    string private _symbol;

    // Mapping from token ID to owner's address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId_) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId_ == type(IERC1238).interfaceId ||
            super.supportsInterface(interfaceId_);
    }

    /// @dev Returns the badge's name
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /// @dev Returns the badge's symbol
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC1238Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        require(_exists(tokenId_), "ERC1238URIStorage: URI query for nonexistent token");
        return _tokenURIs[tokenId_];
    }

    // Returns the number of tokens owned by `owner`
    function balanceOf(address owner_) public view virtual override returns (uint256) {
        require(owner_ != address(0), "Invalid owner at zero address");
        return _balances[owner_];
    }

    /// @dev Returns the owner of a given token ID, reverts if the token does not exist
    function ownerOf(uint256 tokenId_) public view virtual override returns (address) {
        require(_exists(tokenId_), "Token is not minted");
        address owner = _owners[tokenId_];
        require(owner != address(0), "Invalid owner at zero address");
        return owner;
    }

    /// @dev Checks if a token ID exists
    function _exists(uint256 tokenId_) internal view virtual returns (bool) {
        return _owners[tokenId_] != address(0);
    }

    /// @dev Mints `tokenId` and transfers it to `to`.
    function _mint(address to_, uint256 tokenId_) internal virtual {
        require(to_ != address(0), "Invalid owner at zero address");
        require(!_exists(tokenId_), "Token already minted");

        _balances[to_] += 1;
        _owners[tokenId_] = to_;

        emit Minted(to_, tokenId_);
    }

    /// @dev Burns `tokenId`.
    function _burn(uint256 tokenId_) internal virtual {
        address owner = ERC1238.ownerOf(tokenId_);

        delete _owners[tokenId_];

        if (_balances[owner] == 1) {
            delete _balances[owner];
        } else {
            _balances[owner] -= 1;
        }

        if (bytes(_tokenURIs[tokenId_]).length != 0) {
            delete _tokenURIs[tokenId_];
        }

        emit Burned(owner, tokenId_);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     */
    function _setTokenURI(uint256 tokenId_, string memory tokenURI_) internal virtual {
        require(_exists(tokenId_), "ERC1238URIStorage: URI set of nonexistent token");
        require(_owners[tokenId_] == _msgSender(), "ERC1238URIStorage: Sender address is not the owner of the token!");
        _tokenURIs[tokenId_] = tokenURI_;
        emit TokenURISet(tokenId_, tokenURI_);
    }
}