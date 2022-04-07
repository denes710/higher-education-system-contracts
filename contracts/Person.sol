// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IPerson.sol";
import "./Token/ERC1238/ERC1238.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Person is Ownable, IPerson, ERC1238 {
    using Counters for Counters.Counter;

    // last person unique id
    Counters.Counter public _tokenId;
    // Mapping owner address to token
    mapping(address => uint256) private _tokens;

    constructor(string memory name_, string memory symbol_) ERC1238(name_, symbol_) {}

    function tokenOf(address owner_) public view virtual override returns (uint256) {
        return _tokens[owner_];
    }

    function mint(address to_) onlyOwner virtual public {
        _tokenId.increment();
        // One address can own only one token
        require(balanceOf(to_) == 0, "The address already owns a token!");
        super._mint(to_, _tokenId.current());
        _tokens[to_] = _tokenId.current();
    }

    function burn(uint256 tokenId_) onlyOwner virtual public {
        address owner = ownerOf(tokenId_);
        super._burn(tokenId_);
        delete _tokens[owner];
    }

    function setTokenURI(uint256 tokenId_, string memory tokenURI_) virtual public {
        super._setTokenURI(tokenId_, tokenURI_);
    }
}