# Chapter 7: Testing Smart Contracts

## Introduction
Smart contract testing is crucial for ensuring code reliability and security before deployment.
Unlike traditional software, smart contracts are immutable once deployed, making thorough testing essential.
This chapter covers comprehensive testing strategies using Foundry, from basic unit tests to advanced property verification.

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

1. Foundry -- allows you to write tests in Solidity, providing a native testing environment that closely mirrors production conditions.
This approach offers several advantages over JavaScript-based testing frameworks.

**Unique Features:**
- Native fuzzing capabilities with automatic input generation
- Gas optimization reports and profiling
- Built-in cheatcodes for precise state manipulation
- Mainnet forking for realistic integration testing


### Project Setup
In your Foundry project, tests should follow this structure:
```Solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GLDToken} from "../src/GLDToken.sol";

contract GLDTokenTest is Test {
    // Test implementation goes here
}
```
The `Test` contract from `forge-std` provides assertion functions and access to cheatcodes that make testing powerful and expressive.
`Cheatcodes` are a particularity of the Foundry toolkit.
You can look at them as special functions that allow users to change a block number, your identity, your account balance.
[read more](https://getfoundry.sh/forge/tests/cheatcodes/).

The `console` is a library which allows users to log messages and values during a test execution.

Time to write some tests.

### Unit testing
Unit testing focuses on individual contract functions in isolation.
Let's build a comprehensive test suite for an ERC20 token to demonstrate best practices.

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
 - we deploy a new contract for our `ERC20`; the parameter represents the initial supply of tokens that will be minted.
 - we assert that the owner of the contract is the address of the test contract, from which the message was sent.
 - finally we assert the balance of the owner is equal to the initial supply.

To run the tests we can run
```
>$ forge build
>$ forge test
```
![image](https://gist.github.com/user-attachments/assets/a7acf60b-1983-447d-b23d-558bf14d4edf)

We can see that the test is passing, and that there are no skipped/failing tests so far.

This test verifies deployment correctness, but has limitations: it uses hardcoded values and lacks reusability.
First of all, the values used for testing are constant: we are testing a very specific scenario with a single value being transferred.
Additionally, there is the boilerplate code.
For next tests that we plan to write, we would need to repeat the deployment of the contract and the setup of the accounts.

#### The `setUp` function
Foundry allows users to define an initial state for all the tests to run in.
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
Fuzz testing automatically generates random inputs to test edge cases you might not consider manually.
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

## Integration Testing

Integration testing verifies that multiple contracts work together correctly.
This often involves testing complex interactions and state changes across contract boundaries.

### Fork Testing

Fork testing allows you to test against real blockchain state, providing a more realistic testing environment.
Forge supports testing in a forked environment with two different approaches:
1. Forking Mode: use a single fork for all your tests via the `forge test --fork-url` flag
2. Forking Cheatcodes - create, select and manage multiple forks directly in the Solidity test code via [forking cheatcodes](https://getfoundry.sh/reference/cheatcodes/forking/)

Both instances will require for you to have a fork key from an RPC provider.
You can get access to nodes for the most popular networks from providers such as Infura or Alchemy.
Keep in mind to always keep your API-key private and don't publish it in your code or in your staged repository files.

One setup example is to have a `.env` file with your keys:
```bash
# .env
MAINNET_RPC_URL=https://mainnet.infura.io/v3/your-api-key
GOERLI_RPC_URL=https://goerli.infura.io/v3/your-api-key
POLYGON_RPC_URL=https://polygon-mainnet.infura.io/v3/your-api-key
```

Reference them in `foundry.toml`:
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
goerli = "${GOERLI_RPC_URL}"
polygon = "${POLYGON_RPC_URL}"

# Or directly in profiles
[profile.mainnet]
rpc_url = "${MAINNET_RPC_URL}"

[profile.goerli]
rpc_url = "${GOERLI_RPC_URL}"
```

Foundry will automatically load the `.env` file from project root, allowing you to run either
1. `forge test --fork-url mainnet`
2. `FOUNDRY_PROFILE=mainnet forge test`
3. using the env url in the `setUp` function
```Solidity
    function setUp() public {
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(mainnetFork);
    }
```

Make sure to always have your `.env` file in the `.gitignore` file.

### Invariant testing
sum of `_balances` == `totalSupply` example

### Symbolic execution:
Symbolic execution is a technique that explores all possible execution paths of a program by treating inputs as symbolic variables rather than concrete values.
Unlike fuzzing that tests with random samples, symbolic execution can be used to mathematically prove properties across all possible inputs.

Tools such as Halmos and Kontrol are compatible with Foundry and should work out of the box with a Foundry test suite.

#### References & good reads
https://book.getfoundry.sh/
