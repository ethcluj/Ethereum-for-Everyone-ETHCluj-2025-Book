# Chapter 7: Testing Smart Contracts

## Introduction
Learn comprehensive testing strategies for smart contract development.

## Topics Covered
- [Testing frameworks](#testing-frameworks)
- [Unit testing](#unit-testing)
- [Integration testing](#fork-testing)
- [Test networks](#fork-testing)
- Coverage analysis
- [Automated testing](#symbolic-execution)
- Test-driven development (TDD)

## Prerequisites
- Basic Solidity knowledge
- Understanding of testing concepts
- Familiarity with JavaScript/TypeScript

### Testing frameworks

1. Foundry - Allows users to write tests in Solidity by defining a test contract that imports the contract that's targeted for testing.
Unique Features:
- Native fuzzing capabilities
- Gas optimization reports
- Built-in cheatcodes for state manipulation
- Forking capabilities

2. Hardhat - Allows users to write tests in JavaScript or TypeScript.
Unique Features:
- Extensive plugin ecosystem
- Console.log in Solidity
- Built-in Solidity stack traces
- Hardhat Network with forking capabilities
- TypeScript support

In the attached repository, there are projects for both Foundry and Hardhat of an ERC20 token, for which we will write some tests.(#TODO)

Let’s go over the most common way of writing tests.
The test file in the repo, should look close to this:
```Solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GLDToken} from "../src/GLDToken.sol";

contract GLDTokenTest is Test {

    //TODO: write tests here
}
```
Time to write some tests.
### Unit testing
Functions prefixed with `test` are considered to be a test case to run.
Let's define a basic test for an ERC20 called `GLDToken`. 

```Solidity
    function test_deployment() public {
        address receiver = address(0x100);
        uint256 initial_supply = 100 * 10 ** 18;

        GLDToken token = new GLDToken(initial_supply);
        assertEq (token.owner(), address(this));
        assertEq (token.balanceOf(address(this)), initial_supply);
    }
```

Let's analyze what happens above:
 - we define a receiver address, `0x100`.
 - we define an initial_supply value of (100 * 10 ** 18), which represents an amount of 100 tokens with 18 decimals of precision.
 - we deploy a new contract for our `ERC20`. the parameter represents the initial supply of tokens that will be minted.
 - we assert that the owner of the contract is the address of the test contract, from which the message was sent.
 - finally we assert the balance of the owner is equal to the initial supply.

To run the tests we can run
```
>$ forge build
>$ forge test
```
![image](https://gist.github.com/user-attachments/assets/a7acf60b-1983-447d-b23d-558bf14d4edf)

We can see that the test is passing, and that there are no skipped/failing tests so far.

However, there are a few limitations with this test.
First of all, the values used for testing are constant: we are testing a very specific scenario with a single value being transferred.
Additionally, there is the boilerplate code.
For next tests that we plan to write, we would need to repeat the deployment of the contract and the setup of the accounts.

#### The `setUp` function
Both testing frameworks allow users to define an initial state for all the tests to run in.
In Foundry, the `setUp` function is an optional function invoked before each test case is run.
Using a `setUp` improves the maintainability and readability of your test suite by avoiding code duplication.

```Solidity
contract GLDTokenTest is Test {
    GLDToken token;
    uint initial_supply;

    function setUp() public {
        initial_supply = 100 * 10 ** 18;
        token = new GLDToken(initial_supply);
    }

    function test_deployment() public view {
        assertEq (token.owner(), address(this));
        assertEq (token.balanceOf(address(this)), initial_supply);
    }
}
```

#### Fuzz testing
Now, let's write a test for a transfer scenario while also trying to make the test a bit more general.
I'm attaching a diff below so that the example is easier to follow.
```diff
 contract GLDTokenTest is Test {
     GLDToken token;
     uint initial_supply;
+    address alice;
+    uint balance_alice;
 
     function setUp() public {
         initial_supply = 100 * 10 ** 18;
         token = new GLDToken(initial_supply);
+
+        alice = address(0x100);
+        balance_alice = 50 * 10 ** 18;
+        token.transfer(alice, balance_alice);
     }
 
     function test_deployment() public view {
         assertEq (token.owner(), address(this));
-        assertEq (token.balanceOf(address(this)), initial_supply);
+        assertEq (token.balanceOf(address(this)), initial_supply - balance_alice);
+        assertEq (token.balanceOf(alice), balance_alice);
+    }
+
+    function test_transfer(uint256 amount) public {
+        vm.assume(amount <= balance_alice);
+        address bob = vm.randomAddress();
+        //impersonating Alice
+        vm.prank(alice);
+        bool status = token.transfer(bob, amount);
+        assertTrue(status);
+        assertEq(token.balanceOf(bob), amount);
+        assertEq(token.balanceOf(alice), balance_alice-amount);
     }
 }
 ```
- adding a new user, called `alice`, and we define it's own balance `balance_alice`.
- updating the `setUp` to initialize `alice` and transfer her balance from the `owner`.
- updating the `test_deployment` function to account for the change in balances.

Now we're adding a new test named `test_transfer(uint256 amount)` in which we want to check the transfer functionality of the ERC20 contract.
The argument of the function, `uint256 amount` is a test variable.
Foundry will assign random values to this argument before the test is executed.
What's also new, are the `vm.` calls, which are called cheatcodes.

#### Cheatcodes

These do not have a propper implementation in Solidity and are only defined at the Interface level.
In reality, cheatcodes are handy shortcircuits of the EVM implementation used by Foundry which enable users to manipulate the state of the blockchain, as well as test for specific reverts and events.

In the `test_transfer(uint256 amount)` example above, the cheatcodes used are:
 - `vm.assume(bool condition)` - If the boolean expression evaluates to false, the fuzzer will discard the current fuzz inputs and start a new fuzz run. [read more](https://book.getfoundry.sh/cheatcodes/assume?highlight=assume#assume)
 - `vm.prank()` - Sets msg.sender to the specified address for the next call. [read more](https://book.getfoundry.sh/cheatcodes/prank?highlight=prank#prank) 
 - `vm.expectRevert()` - Used when a call is expected to revert. If the call does not revert, this cheatcode will. [read more](https://book.getfoundry.sh/cheatcodes/expect-revert?highlight=expectRevert#expectrevert)
 - `vm.expectEmit(bool, bool, bool, bool)` [read more]()

Running `forge test`, we can see that the `test_transfer` has been executed for `256` runs, each time with a different random input.
![image](https://gist.github.com/user-attachments/assets/5d355edd-7941-4128-98ae-fe21fe8b7221)

The number of runs can be customized using the `--fuzz-runs` flag.

Additionally, if you want to run a subset of the available tests, you can use:
 - `--match-test <REGEX>` / `--no-match-test <REGEX>` - Only run test functions matching the specified regex pattern.         
 - `--match-contract <REGEX>` / `--no-match-contract <REGEX>` - Only run tests in contracts matching the specified regex pattern.
 - `--match-path <GLOB>` / `--no-match-path <GLOB>` - Only run tests in source files matching the specified glob pattern.

A good practice is to also test for emmited events using `vm.expectEmit()`.
For example, we can modify `test_transfer` to get:
```diff
@@ -3,6 +3,7 @@ pragma solidity ^0.8.13;
 
 import {Test, console} from "forge-std/Test.sol";
 import {GLDToken} from "../src/GLDToken.sol";
+import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 
 contract GLDTokenTest is Test {
     GLDToken token;
@@ -28,6 +29,8 @@ contract GLDTokenTest is Test {
     function test_transfer(uint256 amount) public {
         vm.assume(amount <= balance_alice);
         address bob = vm.randomAddress();
+        vm.expectEmit(true, true, false, true);
+        emit IERC20.Transfer(alice, bob, amount);
         //impersonating Alice
         vm.prank(alice);
         bool status = token.transfer(bob, amount);
```

### Fork testing
TBD

### Invariant testing
sum of `_balances` == `totalSupply` example

### Symbolic execution:
Symbolic execution is a technique that explores all possible execution paths of a program by treating inputs as symbolic variables rather than concrete values.
Unlike fuzzing that tests with random samples, symbolic execution can be used to mathematically prove properties across all possible inputs.

Tools such as Halmos and Kontrol are compatible with Foundry and should work out of the box with a Foundry test suite.

#### References & good reads
https://book.getfoundry.sh/
