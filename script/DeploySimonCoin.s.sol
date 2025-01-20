// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {SimonCoin} from "src/SimonCoin.sol";

contract DeploySimonCoin is Script {
    uint256 private constant INITIAL_SUPPLY = 1_000_000 ether;

    function run () public  returns (SimonCoin) {
        vm.startBroadcast();
        SimonCoin coin = new SimonCoin(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return coin;
    }
}