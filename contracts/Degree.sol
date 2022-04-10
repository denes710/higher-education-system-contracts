// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDegree.sol";

import "./Token/ERC1238/ERC1238.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Degree is Ownable, ERC1238, IDegree {
    using Counters for Counters.Counter;

    // mapping degree with credit value
    mapping(uint256 => uint32) public creditValues;

    // last degree unique id
    Counters.Counter private _tokenId;

    constructor(string memory name_, string memory symbol_) ERC1238(name_, symbol_) {}

    function mint(address to_, uint32 sumMarks_, uint32 sumCredits_) onlyOwner public {
        _tokenId.increment();
        super._mint(to_, _tokenId.current());
        creditValues[_tokenId.current()] = (sumMarks_ + sumCredits_) * 1000 / 30;
        emit CreditValue(_tokenId.current(), creditValues[_tokenId.current()]);
    }

    // Burning functionality is removed
    function _burn(uint256) pure internal override {
        require(false, "Burning is not possible!");
    }

    function setTokenURI(uint256 tokenId_, string memory tokenURI_) virtual public {
        super._setTokenURI(tokenId_, tokenURI_);
    }
}