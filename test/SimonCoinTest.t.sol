// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DeploySimonCoin} from "script/DeploySimonCoin.s.sol";
import {SimonCoin} from "src/SimonCoin.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20Errors} from "openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";

contract SimonCoinTest is Test {
    SimonCoin simonCoin;
    DeploySimonCoin deployer;

    address owner;
    address bob;
    address alice;

    function setUp() public {
        owner = makeAddr("owner");
        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployer = new DeploySimonCoin();
        simonCoin = deployer.run(owner);
    }

    function testInitialSupply() public view {
        // Assert that the initial supply is correctly minted to the owner
        assertEq(simonCoin.balanceOf(owner), deployer.INITIAL_SUPPLY());
    }

    function testTokenNameAndSymbol() public view {
        // Assert that the token name and symbol are correct
        assertEq(simonCoin.name(), "SimonCoin", "Incorrect token name");
        assertEq(simonCoin.symbol(), "SIC", "Incorrect token symbol");
    }

    function testOnlyOwnerModifier() public {
        vm.prank(bob);
        vm.expectRevert(SimonCoin.SimonCoin__NotOwner.selector);

        // Attempt an owner-restricted action to trigger the revert
        simonCoin.rugpull(payable(bob));
    }

    function testRugPull() public {
        vm.prank(owner);
        simonCoin.rugpull(payable(bob));
    }

    function testTransferFunction() public {
        uint256 transferAmount = 100 ether;

        // Owner transfers tokens to a non-owner
        vm.prank(owner);
        simonCoin.transfer(bob, transferAmount);

        // Assert balances after the transfer
        assertEq(
            simonCoin.balanceOf(owner),
            deployer.INITIAL_SUPPLY() - transferAmount,
            "Owner balance incorrect after transfer"
        );
        assertEq(simonCoin.balanceOf(bob), transferAmount, "Non-owner balance incorrect after transfer");
    }

    function testRevertOnInvalidTransfer() public {
        uint256 transferAmount = deployer.INITIAL_SUPPLY() + 1 ether; // More than the owner's balance

        // Expect revert due to insufficient balance
        vm.startPrank(owner);
        //vm.expectRevert(IERC20Errors.ERC20InsufficientBalance.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector, owner, simonCoin.balanceOf(owner), transferAmount
            )
        );
        simonCoin.transfer(bob, transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 approveAmount = 500 ether;
        uint256 transferAmount = 300 ether;

        // Owner approves non-owner to spend tokens
        vm.prank(owner);
        simonCoin.approve(bob, approveAmount);

        // Assert allowance
        assertEq(simonCoin.allowance(owner, bob), approveAmount, "Allowance incorrect after approve");

        // Non-owner transfers tokens from the owner's account
        vm.prank(bob);
        simonCoin.transferFrom(owner, bob, transferAmount);

        // Assert balances and remaining allowance
        assertEq(
            simonCoin.balanceOf(owner),
            deployer.INITIAL_SUPPLY() - transferAmount,
            "Owner balance incorrect after transferFrom"
        );
        assertEq(simonCoin.balanceOf(bob), transferAmount, "Non-owner balance incorrect after transferFrom");
        assertEq(
            simonCoin.allowance(owner, bob), approveAmount - transferAmount, "Allowance incorrect after transferFrom"
        );
    }
}
