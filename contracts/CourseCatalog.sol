// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Library/Common.sol";
import "./Token/ERC1238/ERC1238.sol";
import "./Person.sol";
import "./University.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @dev Implementation of the available courses which can be used during a semester.
 */
 contract CourseCatalog is ERC1238 {
    using Counters for Counters.Counter;
    using Common for Common.State;

    // mapping course with credit value
    mapping(uint256 => uint8) public creditValues;

    // last course unique id
    Counters.Counter private _tokenId;
    // main university smart contract
    University private _university;

    constructor(string memory name_, string memory symbol_, address universityAddr_) ERC1238(name_, symbol_) {
        _university = University(universityAddr_);
    }

    function mint(uint8 creditValue_) offSeason public {
        require(_university.teacher().balanceOf(_msgSender()) == 1, "Only teacher can mint a course!");
        _tokenId.increment();
        super._mint(_msgSender(), _tokenId.current());
        creditValues[_tokenId.current()] = creditValue_;
    }

    function burn(uint256 tokenId_) offSeason public {
        require(ERC1238.ownerOf(tokenId_) == _msgSender(), "Sender is not the owner!");
        super._burn(tokenId_);
        delete creditValues[tokenId_];
    }

    function setTokenURI(uint256 tokenId_, string memory tokenURI_) modifiableState public {
        require(ERC1238.ownerOf(tokenId_) == _msgSender());
        super._setTokenURI(tokenId_, tokenURI_);
    }

    modifier modifiableState() {
        require(_university.currentState() == Common.EState.offSeason ||
            _university.currentState() == Common.EState.planning,
            "Course catalog cannot be modified in the current state!");
        _;
    }

    modifier offSeason() {
        require(_university.currentState() == Common.EState.offSeason,
            "Course catalog is not in the off season!");
        _;
    }
}
