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
