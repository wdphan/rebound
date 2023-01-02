// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import {MyNFT} from "src/MyNFT.sol";
import "node_modules/forge-std/src/Test.sol";


contract Rebound is Test {

    Rebound public rebound;
    MyNFT public nft;

    address bob = vm.addr(111);

    function setUp() public {
        rebound = new Rebound();
        vm.label(bob, "BOB");
        vm.deal(bob, 100 ether);
    }

    function testMint() public {
        nft.safeMint(bob, 1);
        nft.safeMint(bob, 2);
    }

    function testFailMint() public {
        nft.safeMint(bob, 1);
        nft.safeMint(bob, 1);
    }

    
}