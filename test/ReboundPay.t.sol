// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import {MyNFT} from "src/MyNFT.sol";
import "src/ReboundPay.sol";
import "node_modules/forge-std/src/Test.sol";
import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ReboundTest is Test {

    ReboundPay public reboundpay;
    MyNFT public nft;

    address bob = vm.addr(111);
    address bill = vm.addr(222);

    function setUp() public {
        reboundpay = new ReboundPay("ReboundPay","RBPY");
        nft = new MyNFT();

        // contract can access tokens
        nft.setApprovalForAll(address(reboundpay), true);

        // Ensure contract can access user's tokens
		vm.prank(address(bob));
        nft.setApprovalForAll(address(reboundpay), true);

        // Ensure contract can access user's tokens
		vm.prank(address(bill));
        nft.setApprovalForAll(address(reboundpay), true);

        vm.label(bob, "BOB");
        vm.deal(bob, 100 ether);

        vm.label(bill, "BILL");
        vm.deal(bob, 100 ether);
    }

    function testMint() public {
        vm.prank(bob);
        reboundpay.mint(1);
        reboundpay.mint(2);

        assertEq(reboundpay.ownerOf(1), address(bob));
        assertEq(reboundpay.ownerOf(2), address(this));
    }
 
    function testFailMint() public {
        vm.prank(bob);
        reboundpay.mint(1);
        reboundpay.mint(1);

        assertEq(reboundpay.ownerOf(1), address(bob));
    }

    function testSetUser() public {
        reboundpay.mint(1);
        vm.prank(bob);
        reboundpay.setUser(1, bill, 100, 100);
        assertEq(reboundpay._users[1].rentFee, 100);
        assertEq(reboundpay._users[1].marketplaceFee, 1);

        // now bill is operator - true
        reboundpay.isApprovedOrOwner(bill, 1);
        assertEq(reboundpay.ownerOf(1), address(this));

        // pass 101 seconds and check if operator still
        // the same address
        vm.warp(101);
        assertEq(reboundpay.ownerOf(1), address(this));

        // bill is not longer operator
        reboundpay.isApprovedOrOwner(bill, 1);
    }    

    function testFailSetUserWithoutMint() public {
        vm.prank(bob);
        vm.expectRevert();
        reboundpay.setUser(1, bill, 100, 100);
    }

    function testFailSetUserAlreadyRenting() public {
        // renting to Bob
        vm.prank(bob);
        reboundpay.mint(1);
        reboundpay.setUser(1, bill, 100, 100);

        // should fail if rented to Bill
        vm.prank(bill);
        reboundpay.setUser(1, bill, 100, 100);
    }

    function testUserOf() public {
        vm.prank(bob);
        reboundpay.mint(1);
        
        assertEq(reboundpay.ownerOf(1), bob);
    }

     function testFailUserOfWithoutMint() public {
        vm.prank(bob);
        
        assertEq(reboundpay.ownerOf(1), bob);
    }

    function testUserExpires () public {
        reboundpay.mint(1);
        vm.prank(bob);
        reboundpay.setUser(1, bill, 100, 100);
        // owner should still be owner, not Bill
        assertEq(reboundpay.ownerOf(1), address(this));
        // fast forward 101 seconds
        vm.warp(101);
        // owner should still be owner, not Bill
        assertEq(reboundpay.ownerOf(1), address(this));
        assertEq(reboundpay.userExpires(1), 100000000000000000000000000000);
        // Bill should no longer be operator
        reboundpay.isApprovedOrOwner(bill, 1);
    }

    function testFailUserExpires () public {
        reboundpay.mint(1);
        vm.prank(bob);
        reboundpay.setUser(1, bill, 100, 100);
        // owner should still be owner, not Bill
        assertEq(reboundpay.ownerOf(1), address(this));
        // fast forward 90 seconds
        vm.warp(90);
        // owner should still be owner, not Bill
        assertEq(reboundpay.ownerOf(1), address(this));
        assertEq(reboundpay.userExpires(1), 90);
        // Bill should still be operator
        reboundpay.isApprovedOrOwner(bill, 1);
    }

    function testGetRentFee () public {
        reboundpay.mint(1);
        vm.prank(bob);
        reboundpay.setUser(1, bill, 100, 100);
        reboundpay.getRentFee(1);
        assertEq(reboundpay.getRentFee(1), 100);
    }

    function testFailGetRentFeeWithoutMint () public {
        vm.prank(bob);
        reboundpay.setUser(1, bill, 100, 100);
        reboundpay.getRentFee(1);
        assertEq(reboundpay.getRentFee(1), 100);
    }

    function testIsRentable () public {
        reboundpay.mint(1);
        vm.prank(bob);
        reboundpay.setUser(1, bill, 100, 100);
        reboundpay.isRentable(1);
        assertEq(reboundpay.isRentable(1), true);
    }

    function testFailIsRentable () public {
        reboundpay.isRentable(1);
        assertEq(reboundpay.isRentable(1), true);
    }
}