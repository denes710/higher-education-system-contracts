// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Access/Ownable.sol";
import "./Token/ERC1238/ERC1238.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

// FIXME comments
contract Degree is Ownable, ERC1238 {
    using Counters for Counters.Counter;

    // FIXME something credit index is necessary
    Counters.Counter private _tokenId;

    constructor(string memory name_, string memory symbol_) ERC1238(name_, symbol_) {}

    function mint(address to) onlyOwner public {
        super._mint(to, _tokenId.current());
        _tokenId.increment();
    }

    // Burning functionality is removed
    function _burn(uint256 tokenId) internal override {}
}