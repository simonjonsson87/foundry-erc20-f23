// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract SimonCoin is ERC20 {
    address owner;

    error SimonCoin__NotOwner();

    modifier onlyOwner() {
        require(msg.sender != owner, SimonCoin__NotOwner());
        _; 
    }
    constructor (uint256 initialSupply) ERC20("SimonCoin", "SIC") {
        _mint(msg.sender, initialSupply);
        owner = msg.sender;
    }

}