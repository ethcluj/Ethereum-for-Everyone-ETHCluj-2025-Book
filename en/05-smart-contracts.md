# 📘 Chapter 5 – Smart Contracts Demystified

This subchapter introduces smart contracts in a beginner-friendly, hands-on format. 
Smart contracts are the heart of Web3, enabling decentralized, trustless, and automated agreements. In previous chapters, we explored blockchain basics and Ethereum as a foundational platform. Here, we shift our focus to **what** smart contracts are, **how** they work, and **why** they matter. 

---

## 📄 What Is a Smart Contract?

A **smart contract** is a piece of code deployed on the blockchain that runs automatically when conditions are met.

> 🧃 Think of it like a **vending machine**:  
> Insert token → check if valid → dispense product → done.  
> No middleman. No delays. Just rules in code.

---

### 🧠 Real-World Use Cases 
//(all these should be explained with Real-World Analogies Blockchain-Global database with no admin etc...)

Smart contracts bring automation and transparency to many domains:

#### 🏡 Real Estate Tokenization
- Turn a property into **100 tokens**, each representing 1% ownership.
- Sell fractions globally, with transfer logic handled by a smart contract.

#### 🎨 Digital Art & NFTs
- Artists mint their work as **NFTs**, which are unique, trackable tokens.
- Smart contracts handle royalties and ownership automatically.

#### 🚚 Supply Chain
- Products scanned at each checkpoint.
- Data stored on-chain via smart contracts = audit trail.

#### 👨‍⚖️ Escrow & Payments
- Freelance platforms can use contracts to release payments **only when conditions are met**, no human arbitrator needed.

> ✅ All these rely on one key thing: **tokenization** – turning physical or digital rights into programmable assets.

---

## ⚙️ How Smart Contracts Work

- Written in **Solidity**
- Compiled to **EVM bytecode**
- Deployed → lives at an Ethereum address
- Triggered by transactions (need **gas**)

---

## 🚫 Common Pitfalls

- Not auto-secure – bad logic = bugs forever
- No auto-execution – must be triggered
- Mostly immutable – cannot be changed once live

---

## 👨‍💻 Hands-On: Vending Machine Smart Contract

Let's write a basic smart contract that acts like a vending machine.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VendingMachine {
    address public owner;
    mapping(string => uint) public inventory;
    uint public pricePerItem = 0.01 ether;

    constructor() {
        owner = msg.sender;
        inventory["soda"] = 10;
        inventory["chips"] = 15;
    }

    function buyItem(string memory _item) public payable {
        require(inventory[_item] > 0, "Item out of stock");
        require(msg.value >= pricePerItem, "Not enough ETH sent");

        inventory[_item]--;
        // No actual delivery logic – just simulation
    }

    function restock(string memory _item, uint _amount) public {
        require(msg.sender == owner, "Only owner can restock");
        inventory[_item] += _amount;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Challenge
    // function addProduct() public {}
    // how to track what users bought? Ideas? 
}