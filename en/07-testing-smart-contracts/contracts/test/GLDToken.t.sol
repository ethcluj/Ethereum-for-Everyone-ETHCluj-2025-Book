// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GLDToken} from "../src/GLDToken.sol";

contract GLDTokenTest is Test {

    GLDToken token;
    uint256 initial_supply;
    address owner;
    address alice;
    address bob;
    function setUp() public {
        initial_supply = 1000000000 * 10 **18;
        owner = address(0xabc);
        vm.prank(owner);
        token = new GLDToken(initial_supply);
        alice = address(0xaaa);
        bob = address(0xbbb);
        vm.prank(owner);
        token.transfer(alice, 100 * 10 ** 18);
    }
    function test_deployment() public view {
        assertEq(token.symbol(), "GLD");
        assertEq(token.name(), "GLDToken");
        assertEq(token.owner(),owner);
    }

    function testFuzz_transfer(uint256 amount) public {
        uint256 balanceAlice = token.balanceOf(alice);
        vm.assume(amount <= balanceAlice);
        vm.prank(alice);
        bool status = token.transfer(bob, amount );
        assertTrue(status);
    }

    function invariant_transfer() public {
        if(token.balanceOf(alice) >= 1) {
            vm.prank(alice);
            bool status = token.transfer(bob,1);
            assertTrue(status);
        }
    }
}
