// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../interfaces/Token/ERC1238/IERC1238.sol";
import "../../../interfaces/Token/ERC1238/IERC1238Metadata.sol";

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// TODO adds and rewrites comments
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
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1238).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // Returns the badge's name
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    // Returns the badge's symbol
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC1238URIStorage: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    // Returns the token ID owned by `owner`, if it exists, and 0 otherwise
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(owner != address(0), "Invalid owner at zero address");
        return _balances[owner];
    }

    // Returns the owner of a given token ID, reverts if the token does not exist
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(_exists(tokenId), "Token is not minted");
        address owner = _owners[tokenId];
        require(owner != address(0), "Invalid owner at zero address");
        return owner;
    }

    // Checks if a token ID exists
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    // @dev Mints `tokenId` and transfers it to `to`.
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "Invalid owner at zero address");
        require(!_exists(tokenId), "Token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Minted(to, tokenId);
    }

    // @dev Burns `tokenId`.
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC1238.ownerOf(tokenId);

        delete _owners[tokenId];

        if (_balances[owner] == 1) {
            delete _balances[owner];
        } else {
            _balances[owner] -= 1;
        }

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        emit Burned(owner, tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC1238URIStorage: URI set of nonexistent token");
        require(_owners[tokenId] == _msgSender(), "ERC1238URIStorage: TODO");
        _tokenURIs[tokenId] = _tokenURI;
    }
}