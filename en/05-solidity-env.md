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

Just like in traditional web development, we conventionally distinguish between frontend and backend development. These are different disciplines and may or may not be done by the same person/team. By backend development we mean the development of the on-chain logic, i.e., the digital contracts that run on the Ethereum blockchain. By frontend development we mean the development of the user interface, typically a web application that runs in the browser and interacts with the smart contracts via a network protocol. Backend development is sometimes called “on-chain development” or “smart contract development”, while frontend development is sometimes called “off-chain development”. Of course, any functional application needs both, and the two parts need to work together. Still, for the time being this chapter focuses mainly on the on-chain side of your development environment.

# Compilation using solc

The two most essential pieces in any development environment are the Solidity compiler, which translates human-readable Solidity code into machine-executable EVM code, and an Ethereum Virtual Machine that can execute the smart contracts. Let's start with the compiler.

Solidity's first and most widespread compiler is called `solc`. While it's possible to call it directly via the CLI, this is almost never done in practice. The compiler is primarily designed to be invoked by higher-level development frameworks. In fact, you would have to search really hard to find a project that's not using a framework for compilation. We call them frameworks, but they're essentially toolboxes that come with a variety of tools to download the correct compiler version, manage dependencies, call the compiler, deploy your contracts, make interactions, and test your contracts. The two most popular choices these days are Hardhat and Foundry. They offer a similar set of tools that you will need in day-to-day work anyway. That's why these frameworks provide a better starting point for beginners and is also the approach we follow in this chapter.

The frameworks come with different trade-offs and appeal to different development preferences. Ultimately, most developers will work with both these frameworks during their careers. For the sake of brevity, however, we will mainly focus on Foundry. The choice was made because Foundry currently has more active users (according to the Solidity Developer Survey 2024). Luckily, most concepts translate well between the frameworks, and we're seeing that good ideas from one framework are often adopted by the other, leading to some natural convergence which makes it easier for developers to switch between them.

Both Foundry and Hardhat come with excellent documentation and getting-started instructions. We advise all readers to consult the framework documentation directly before starting a new project. This chapter is not a replacement for the documentation; rather, it aims to provide orientation.

Now is the best time to install these tools before you continue reading.

* [Foundry Installation Instructions](https://book.getfoundry.sh/getting-started/installation)
* [Hardhat Installation Instructions](https://hardhat.org/hardhat-runner/docs/getting-started#installation)

# Scaffolding a project

By scaffolding we mean the process of creating all the necessary source files and configuration files needed to kick off the development process of a new project. Development frameworks help with this task.

As a general rule, Foundry is often considered simpler and has become the preferred choice for many smart contract developers in recent years because it offers a well-rounded testing framework that allows devs to write their tests in Solidity. Hardhat, on the other hand, is considered more flexible and programmable, and is often the preferred choice of frontend developers because of its JavaScript testing framework. Notably, Hardhat now also supports Solidity tests.

## Project Structure

To scaffold a new Foundry project you can run the `forge init` command. It creates the following files and folders:

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

# Local Blockchain

We have seen how to compile your contracts with Foundry. Now, we turn our attention to **executing** your contracts. Executing is not as straightforward as running a C program. It requires multiple steps: first, we must set up a local blockchain that can run your code—you can picture this step as setting up a virtual machine. Next, we must deploy your contracts, which means uploading them to the local blockchain. Finally, we can interact with the contracts by sending transactions from a test account.

Smart contracts are executed on an EVM chain. We say “a chain” and not “the chain” because there are many different independent networks. For development purposes, we're typically running our own local blockchain rather than a public blockchain. The terms “chain”, “network”, and “node” are often used interchangeably. We're using local testnets because they offer us greater performance (no networking and consensus overhead), are cheaper (no gas costs), and they don't leave public traces on the Internet. Local testnets also come with some enhanced debugging features that are often missing from production-grade public nodes.

Foundry comes with a local node called “Anvil”. Hardhat's local node is called “Hardhat Network”.

### Deploying a contract

TODO

### Sending a transaction

TODO

# Debugging smart contracts

TODO

# Deployment and Source Code Verification

TODO
