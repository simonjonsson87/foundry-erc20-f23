// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {SimonCoin} from "src/SimonCoin.sol";

contract DeploySimonCoin is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function run(address owner) public returns (SimonCoin) {
        vm.startBroadcast(owner);
        SimonCoin coin = new SimonCoin(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return coin;
    }
}
