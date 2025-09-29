// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Redemption Contract
/// @notice Holds CYRD and transfers to users upon backend-verified redemption
contract Redemption is Ownable {
    IERC20 public immutable token;
    address public backend;

    event BackendUpdated(address indexed backend);
    event Redeemed(address indexed to, uint256 amount);

    error NotAuthorized();

    constructor(address initialOwner, IERC20 _token, address _backend) Ownable(initialOwner) {
        token = _token;
        backend = _backend;
    }

    function setBackend(address _backend) external onlyOwner {
        backend = _backend;
        emit BackendUpdated(_backend);
    }

    function redeem(address to, uint256 amount) external {
        if (msg.sender != backend) revert NotAuthorized();
        require(token.transfer(to, amount), "transfer failed");
        emit Redeemed(to, amount);
    }
}
