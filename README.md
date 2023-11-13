## Contract Address

[0x08800aEB77963Bc804133d75255DE25f843eAAad](https://testnet.snowtrace.io/address/0x08800aEB77963Bc804133d75255DE25f843eAAad)

## Video Links

I have 2 videos showcasing my contract walkthrough and functionality

[Degen Contract walkthrough 1](https://www.loom.com/share/8d605b6afffb454d86a68f0eb5447892?sid=ac91eee6-27f0-47db-b4ca-34c90e10eb3f)

[Degen Contract walkthrough 2](https://www.loom.com/share/a8dbdc22ce6b419792e27c50c0ce0457?sid=c56e4b62-83b1-4404-b39f-3b29990ddd6f)

# Getting Started

## Functionality

Contract Degen is ERC20:

This contract inherits from the ERC-20 contract, which means it includes all the standard ERC-20 token functionality.
owner:

An address variable to store the owner's Ethereum address. The owner has special privileges, including minting new tokens and creating redeemable game items.
RedeemableGameItem Struct:

A struct that defines the structure of a redeemable game item. It includes fields for the item's ID, name, the number of tokens required to redeem it, whether it has been redeemed, and the current owner.
redeemableItems Mapping:

A mapping that associates item IDs (represented by uint256) with RedeemableGameItem structs. This mapping is used to store information about redeemable game items.
nextItemId:

A variable that keeps track of the next available item ID. This is used to assign unique IDs to new redeemable game items.
Events:

Two events, ItemCreated and ItemRedeemed, are defined to log important events within the contract.
Constructor:

The constructor initializes the contract with the name "Degen" and the symbol "DGN." It also sets the owner to the address of the contract deployer (the person who deploys the contract).
onlyOwner Modifier:

A custom modifier that restricts certain functions to be callable only by the owner of the contract. This ensures that only the owner can perform specific actions.
mint Function:

The mint function allows the owner to create new tokens and send them to a specified address. This function is protected by the onlyOwner modifier.

transferTokens Function:
This function enables users to transfer tokens to another address. It checks if the sender has a sufficient balance before executing the transfer.

checkBalance Function:
This function allows users to check their token balance.

burn Function:
Users can burn (destroy) a specific amount of their own tokens. This reduces their token balance.

createRedeemableItem Function:
The owner can create redeemable game items by specifying a name and the number of tokens required to redeem the item. Each new item is assigned a unique ID and added to the redeemableItems mapping.

redeemItem Function:
Users can redeem a specific item if they have enough tokens. The function checks if the item exists, has not been redeemed, and if the user has enough tokens to redeem it. If conditions are met, the item is transferred to the user.

checkItem Function:
Users can check the details of a specific redeemable game item by providing its ID.

This contract combines the functionality of an ERC-20 token with a system for creating and redeeming in-game items using tokens, giving the owner control over item creation

### Executing program

To run this program, you need to use Foundry;

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Degen is ERC20 {
    address public owner;
    struct RedeemableGameItem {
        uint256 id;
        string name;
        uint256 requiredTokens;
        bool redeemed;
        address owner;
    }

    mapping(uint256 => RedeemableGameItem) public redeemableItems;
    uint256 public nextItemId;

    event ItemCreated(uint256 itemId, string name, uint256 requiredTokens);
    event ItemRedeemed(uint256 itemId, string name);

    constructor() ERC20("Degen", "DGN") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

      function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transferTokens(address to, uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, to, amount);
    }

    function checkBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }

    function createRedeemableItem(string memory _name, uint256 _requiredTokens) public {
        require(msg.sender == owner, "Only the owner can create items");
        nextItemId++;
        redeemableItems[nextItemId] = RedeemableGameItem(
            nextItemId,
            _name,
            _requiredTokens,
            false,
            msg.sender
        );

        emit ItemCreated(nextItemId, _name, _requiredTokens);
    }

    function redeemItem(uint256 _itemId) public {
        require(redeemableItems[_itemId].id == _itemId, "Item does not exist");
        require(!redeemableItems[_itemId].redeemed, "Item has already been redeemed");

        _transfer(msg.sender, redeemableItems[_itemId].owner, redeemableItems[_itemId].requiredTokens);

        redeemableItems[_itemId].owner = msg.sender;
        redeemableItems[_itemId].redeemed = true;
        emit ItemRedeemed(_itemId, redeemableItems[_itemId].name);


        emit ItemRedeemed(_itemId, redeemableItems[_itemId].name);
    }

    function checkItem(uint256 _itemId) public view returns (RedeemableGameItem memory) {
        return redeemableItems[_itemId];
    }

}

```

## Test file

```javascript

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



```

## Authors

DamKols

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
