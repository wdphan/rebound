// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import {MyNFT} from "src/MyNFT.sol";
import "src/Rebound.sol";
import "node_modules/forge-std/src/Test.sol";


contract ReboundTest is Test {

    Rebound public rebound;
    MyNFT public nft;

    address bob = vm.addr(111);

    function setUp() public {
        rebound = new Rebound("Rebound","RBND");
        nft = new MyNFT();

        // contract can access tokens
        nft.setApprovalForAll(address(rebound), true);

        // Ensure contract can access user's tokens
		vm.prank(address(bob));
        nft.setApprovalForAll(address(rebound), true);

        vm.label(bob, "BOB");
        vm.deal(bob, 100 ether);
    }

    function testMint() public {
        nft.safeMint(bob, 1);
        nft.safeMint(bob, 2);
    }

    function testSetUser() public {
        nft.safeMint(bob, 1);
        rebound.setUser(0, bob, 100);
    }    
}