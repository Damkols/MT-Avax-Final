// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Degen.sol";

contract DegenTest is Test {
    Degen public degen;

     struct RedeemableGameItem {
        uint256 id;
        string name;
        uint256 requiredTokens;
        bool redeemed;
        address owner;
    }

    
    address owner = makeAddr("owner");
    address recipient = makeAddr("recipient");
    address testRecipient = makeAddr("testRecipient");

    function setUp() public {
        vm.startPrank(owner);
        degen = new Degen();
        vm.stopPrank();
    }

    function testMint() public {
        assertEq(degen.balanceOf(recipient), 0);
        
        vm.startPrank(owner);

        degen.mint(recipient, 100);
        assertEq(degen.balanceOf(recipient), 100);
        vm.stopPrank();
    }

    function testTransferTokens() public {
        testMint();
        vm.startPrank(recipient);

        degen.transferTokens(testRecipient, 50);
        assertEq(degen.balanceOf(recipient), 50);
        assertEq(degen.balanceOf(testRecipient), 50);
        vm.stopPrank();
    }

    function testCheckBalance() public {
        vm.startPrank(owner);
        degen.mint(recipient, 100);
        assertEq(degen.checkBalance(recipient), 100);
    }

    function testBurn() public {
        testCheckBalance();
        vm.startPrank(recipient);
        degen.burn(50);
        assertEq(degen.balanceOf(recipient), 50);
    }

    function testCreateRedeemableItem() public {
        vm.startPrank(owner);
        string memory itemName = "Cool Sword";
        uint256 requiredTokens = 100;

        degen.createRedeemableItem(itemName, requiredTokens);
        assertEq(degen.checkItem(1).name, itemName);
        assertEq(degen.checkItem(1).requiredTokens, requiredTokens);

    }

    function testRedeemItem() public {
        vm.startPrank(owner);
        degen.mint(recipient, 200);
        string memory itemName = "Cool Sword";
        uint256 requiredTokens = 100;

        degen.createRedeemableItem(itemName, requiredTokens);
        vm.stopPrank();

        vm.startPrank(recipient);
        degen.redeemItem(1);

        assertEq(degen.checkItem(1).redeemed, true);
    }
}
