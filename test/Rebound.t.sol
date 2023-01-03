// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import {MyNFT} from "src/MyNFT.sol";
import "src/Rebound.sol";
import "node_modules/forge-std/src/Test.sol";
import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ReboundTest is Test {

    Rebound public rebound;
    MyNFT public nft;

    address bob = vm.addr(111);
    address bill = vm.addr(222);

    function setUp() public {
        rebound = new Rebound("Rebound","RBND");
        nft = new MyNFT();

        // contract can access tokens
        nft.setApprovalForAll(address(rebound), true);

        // Ensure contract can access user's tokens
		vm.prank(address(bob));
        nft.setApprovalForAll(address(rebound), true);

        // Ensure contract can access user's tokens
		vm.prank(address(bill));
        nft.setApprovalForAll(address(rebound), true);

        vm.label(bob, "BOB");
        vm.deal(bob, 100 ether);

        vm.label(bill, "BILL");
        vm.deal(bob, 100 ether);
    }

    function testMint() public {
        vm.prank(bob);
        rebound.mint(1);
        rebound.mint(2);

        assertEq(rebound.ownerOf(1), address(bob));
        assertEq(rebound.ownerOf(2), address(this));
    }
 
    function testFailMint() public {
        vm.prank(bob);
        rebound.mint(1);
        rebound.mint(1);

        assertEq(rebound.ownerOf(1), address(bob));
    }

    function testSetUser() public {
        rebound.mint(1);
        vm.prank(bob);
        rebound.setUser(1, bill, 100);

        // now bill is operator - true
        rebound.isApprovedOrOwner(bill, 1);
        assertEq(rebound.ownerOf(1), address(this));

        // pass 101 seconds and check if operator still
        // the same address
        vm.warp(101);
        assertEq(rebound.ownerOf(1), address(this));

        // bill is not longer operator
        rebound.isApprovedOrOwner(bill, 1);
    }    

    function testFailSetUserWithoutMint() public {
        vm.prank(bob);
        vm.expectRevert();
        rebound.setUser(1, bill, 100);
    }

    function testFailSetUserAlreadyRenting() public {
        // renting to Bob
        vm.prank(bob);
        rebound.mint(1);
        rebound.setUser(1, bill, 100);

        // should fail if rented to Bill
        vm.prank(bill);
        rebound.setUser(1, bill, 100);
    }

    function testUserOf() public {
        vm.prank(bob);
        rebound.mint(1);
        
        assertEq(rebound.ownerOf(1), bob);
    }

     function testFailUserOfWithoutMint() public {
        vm.prank(bob);
        
        assertEq(rebound.ownerOf(1), bob);
    }

    function testUserExpires () public {
        rebound.mint(1);
        vm.prank(bob);
        rebound.setUser(1, bill, 100);
        // owner should still be owner, not Bill
        assertEq(rebound.ownerOf(1), address(this));
        // fast forward 101 seconds
        vm.warp(101);
        // owner should still be owner, not Bill
        assertEq(rebound.ownerOf(1), address(this));
        assertEq(rebound.userExpires(1), 100000000000000000000000000000);
        // Bill should no longer be operator
        rebound.isApprovedOrOwner(bill, 1);

    }

    function testFailUserExpires () public {
        rebound.mint(1);
        vm.prank(bob);
        rebound.setUser(1, bill, 100);
        // owner should still be owner, not Bill
        assertEq(rebound.ownerOf(1), address(this));
        // fast forward 90 seconds
        vm.warp(90);
        // owner should still be owner, not Bill
        assertEq(rebound.ownerOf(1), address(this));
        assertEq(rebound.userExpires(1), 90);
        // Bill should still be operator
        rebound.isApprovedOrOwner(bill, 1);
    }
}