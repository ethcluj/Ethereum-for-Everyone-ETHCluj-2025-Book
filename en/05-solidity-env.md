# Chapter 5: Setting Up Your Solidity Environment

## Introduction

This chapter aims to be a starting point and hands-on guide for aspiring blockchain developers. We assume basic command-line knowledge, and it certainly helps if you have used an Ethereum application before. We'll introduce the most basic tools you'll need throughout your journey and run you through the first steps of compiling, deploying, and interacting with your smart contract—the “Hello World” of blockchain development.

## Topics Covered

* Development environment setup
* Required tools and software
* IDE configuration
* Compiler settings
* Local blockchain setup
* Testing environment configuration

# Vocabulary

Just like in traditional web development, we conventionally distinguish between frontend and backend development. These are different disciplines and may or may not be done by the same person/team. By backend development, we mean the development of the on-chain logic, i.e., the digital contracts that run on the Ethereum blockchain. By frontend development, we mean the development of the user interface, typically a web application that runs in the browser and interacts with the smart contracts via a network protocol. Backend development is sometimes called “on-chain development” or “smart contract development,” while frontend development is sometimes called “off-chain development.” Of course, any functional application needs both, and the two parts need to work together. Still, for the time being, this chapter focuses only on the on-chain side of your development environment.

# Compilation using solc

The two most essential pieces in any development environment are the Solidity compiler, which translates human-readable Solidity code into machine-executable EVM code, and an Ethereum Virtual Machine that can execute the smart contracts. Let's start with the compiler.

Solidity's first and most widespread compiler is called `solc`. While it's possible to call it directly via the CLI, this is almost never done in practice. The compiler is primarily designed to be invoked by higher-level development frameworks. In fact, you would have to search really hard to find a project that's not using a framework for compilation. We call them frameworks, but they're essentially toolboxes that come with a variety of tools to download the correct compiler version, manage dependencies, call the compiler, deploy your contracts, make interactions, and test your contracts. The two most popular choices these days are Hardhat and Foundry. They offer a similar set of tools that you will need in day-to-day work anyway. That's why these frameworks provide a better starting point for beginners and are also the approach we follow in this chapter.

The frameworks come with different trade-offs and appeal to different development preferences. Ultimately, most developers will work with both these frameworks during their careers. For the sake of brevity, however, we will mainly focus on Foundry. The choice was made because Foundry currently has more active users (according to the Solidity Developer Survey 2024). Luckily, most concepts translate well between the frameworks, and we're seeing that good ideas from one framework are often adopted by the other, leading to some natural convergence which makes it easier for developers to switch between them.

Both Foundry and Hardhat come with excellent documentation and getting-started instructions. We advise all readers to consult the framework documentation directly before starting a new project. This chapter is not a replacement for the documentation; rather, it aims to provide orientation.

Now is the best time to install these tools before you continue reading.

* [Foundry Installation Instructions](https://book.getfoundry.sh/getting-started/installation)
* [Hardhat Installation Instructions](https://hardhat.org/hardhat-runner/docs/getting-started#installation)

# Scaffolding a project

By scaffolding, we mean the process of creating all the necessary source files and configuration files needed to kick off the development process of a new project. Development frameworks help with this task.

As a general rule, Foundry is often considered simpler and has become the preferred choice for many smart contract developers in recent years because it offers a well-rounded testing framework that allows devs to write their tests in Solidity. Hardhat, on the other hand, is considered more flexible and programmable, and is often the preferred choice of frontend developers because of its JavaScript testing framework. Notably, Hardhat now also supports Solidity tests.

## Project Structure

To scaffold a new Foundry project, you can run the `forge init` command. It creates the following files and folders:

```
.
├── README.md
├── foundry.toml
├── lib
├── script
├── src
└── test
```

The `foundry.toml` file contains the project-specific configuration settings. For example, it defines which compilation settings to use.
The `src` folder is the place to add your Solidity files.
The `script` folder contains the code responsible for deploying your smart contract.
The `lib` folder contains code from third-party libraries.
The `test` folder is the place where you add your programmatic tests for quality assurance.

# Compiling

You can compile your project with the `forge build` command. Foundry will take care of downloading and installing the Solidity compiler and dependencies, and invoke the Solidity compiler. The outputs are stored in the `out` folder. The build pipeline allows for granular configuration options, for example, pinpointing a specific solc version or enabling compiler optimizations. We won't cover any of these configuration options in this chapter as the default settings are sufficient for learning purposes.

# Local Blockchain

We have seen how to compile your contracts with Foundry. Now, we turn our attention to **executing** your contracts. Executing is not as straightforward as running a C program. It requires multiple steps: first, we must set up a local blockchain that can run your code—you can picture this step as setting up a virtual machine. Next, we must deploy your contracts, which means uploading them to the local blockchain. Finally, we can interact with the contracts by sending transactions from a test account.

Smart contracts are executed on an EVM chain. We say “a chain” and not “the chain” because there are many different independent networks. For development purposes, we're typically running our own local blockchain rather than a public blockchain. The terms “chain,” “network,” and “node” are often used interchangeably. We're using local testnets because they offer us greater performance (no networking and consensus overhead), are cheaper (no gas costs), and they don't leave public traces on the Internet. Local testnets also come with some enhanced debugging features that are often missing from production-grade public nodes.

Foundry comes with a local node called “Anvil.” Hardhat's local node is called “Hardhat Network.”

To spin up an Anvil node, we can run the `anvil` command. The output tells us the server is now listening and provide a list of unlocked accounts which we can use to interact with the chain. Anvil is a long running server process - in contrast to a one-shot command - and it will block our terminal until we manually shut it down. On most systems we can stop the server using the `CTRL+C` keyboard shortcut. If we want to interact with the server from our terminal, we have to open a new terminal window and keep the one running Anvil active in the background.

### Deploying a contract

Deploying is the process of bringing our smart contracts on-chain. A deployed contract consists of a unique address, it's bytecode and it's persistent storage. The address and bytecode cannot be changed after deployment. The storage can be modified according to the rules laid out by the smart contract logic.

Foundry offers multiple ways to deploy your contracts dependeing on the complexity of your system. A typical protocol consists of multuiple contracts and libraries that must be deployed in a specific order and they must be linked up. Linking the smart contracts is also considered part of the deployment process. But let's start simple - in our first example we want to deploy the `src/Counter.sol` contract from our scaffolded Foundry project to our local Anvil node.

```bash
$ forge create src/Counter.sol:Counter --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Transaction hash: 0x4e0c6273d237516909361d5e63498dc764027575b1dc7f56754b9246c5253e9b
```

Let's break the command down:
- With `src/Counter.sol:Counter` we tell Foundry which contract we want to deploy
- We use `--unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` to authenticate as one of the test users provided by Anvil.
-- With `--broadcast` we instruct Foundry to mine the transaction and not just simulate it.
- The output tells us who deployed the contract, the address of the deployed the contract and the corresponding tx hash.


// TODO: Forge scripts


### Sending a transaction

Our smart contract is now deployed to our local blockchain node. We can now interact with smart contract, which means signing and sending transactions.
Production-ready protocols allow their users to interact with smart contract via a convinient web interface and a wallet extension. As mentioned earlier, building a web frontend is out of scope of this chapter. Instead we show how to sign and send transactions with Foundry. We'll also learn how to read the smart contract state. In theory, reading state can also be performed by executing transactions, but since each tx costs money on live networks (but not on our local blockchain), Ethereum nodes offer additional ways to read state without recording transactions.

Let's start by reading the counter using `cast`.

```
$ cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "number()"
0x0000000000000000000000000000000000000000000000000000000000000000
```

Next, let's send a transaction:

```bash
$ cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "number()" --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
from                 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
gasUsed              43482
status               1 (success)
transactionHash      0xfa7b09450ae592c0103b35a51a503bab2c35aee794ff950c2c81bee0f3d81975
to                   0x5FbDB2315678afecb367f032d93F642f64180aa3
```

Let's verify our counter got incremented by reading the state again:

```
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "number()"
0x0000000000000000000000000000000000000000000000000000000000000001
```

The output confirms that our counter has been incremented by one.

# Debugging smart contracts

TODO

# Deployment and Source Code Verification

TODO
