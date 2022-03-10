// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./Access/Ownable.sol";
import "./Token/ERC1238/ERC1238.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

// FIXME comments
contract Teacher is Ownable, ERC1238 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenId;

    constructor(string memory name_, string memory symbol_) ERC1238(name_, symbol_) {}

    function mint(address to) onlyOwner public {
        // One address can own only one token
        require(balanceOf(to) == 0, "The address already owns a token");
        super._mint(to, _tokenId.current());
        _tokenId.increment();
    }

    function burn(uint256 tokenId) onlyOwner public {
        super._burn(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        super._setTokenURI(tokenId, tokenURI);
    }
}