// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UniversityToken is Ownable, ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        super._mint(_msgSender(), 10000);
    }

    function addNewStudent(address to) onlyOwner public {
        super._mint(to, 100);
    }

    function addNewTeacher(address to) onlyOwner public {
        super._mint(to, 300);
    }
}