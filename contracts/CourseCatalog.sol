// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Access/Ownable.sol";
import "./Token/ERC1238/ERC1238.sol";

import "./Common.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

// FIXME comments
contract CourseCatalog is Ownable, ERC1238 {
    using Counters for Counters.Counter;
    using Common for Common.State;

    Common.State private _currentState;

    Counters.Counter private _tokenId;

    mapping(uint256 => uint8) public _creditValues;

    constructor(string memory name_, string memory symbol_) ERC1238(name_, symbol_) {
        Common.init(_currentState);
    }

    function mint(address to, uint8 creditValue) onlyOwner offSeason public {
        super._mint(to, _tokenId.current());
        _creditValues[_tokenId.current()] = creditValue;
        _tokenId.increment();
    }

    function burn(uint256 tokenId) onlyOwner offSeason public {
        super._burn(tokenId);
        delete _creditValues[tokenId];
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) modifiableState public {
        super._setTokenURI(tokenId, tokenURI);
    }

    modifier modifiableState() {
        require(_currentState.current() == Common.EState.offSeason ||
            _currentState.current() == Common.EState.planning,
            "Course catalog cannot be modified in the current state!");
        _;
    }

    modifier offSeason() {
        require(_currentState.current() == Common.EState.offSeason, "Course catalog is not in the off season!");
        _;
    }

    function setNextState() onlyOwner public {
        Common.nextState(_currentState);
    }
}
