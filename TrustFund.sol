// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract TrustFund {
    uint public totalReceived;                // Total ETH ever received
    uint public lastWithdraw;                 // Last withdrawal timestamp
    bool private locked;                      // Reentrancy guard

    address private immutable fixedOwner = 0x3cC92b7496571fC479EB4714784a6839CD3e57f2;
    address private immutable deployer;        // Owner that deployed the contract

    // Modifiers 
    modifier onlyAuthorized() {
        require(
            msg.sender == fixedOwner || msg.sender == deployer,
            "Caller not authorized"
        );
        _;
    }

    modifier noReentrancy() {
        require(!locked, "Reentrancy blocked"); // Check if it's locked
        locked = true; // if it wasn't locked, lock it
        _; // Carry on
        locked = false; // Unlock it
    }

    constructor() {
        deployer = msg.sender;
    }

    
    // Deposit Ether (SepETH) to the contract.
    function deposit() external payable {
        totalReceived += msg.value;
    }

    // Withdraw up to 1 SepETH if at least 30 minutes have passed since last withdrawal.
    function withdraw(uint amount)
        external
        onlyAuthorized
        noReentrancy
    {
        require(amount <= 1 ether, "Max 1 SepETH per withdrawal"); // Check eth amount
        require(block.timestamp >= lastWithdraw + 30 minutes, "30 min lock active"); // Check time since last withdraw
        require(address(this).balance >= amount, "Insufficient balance"); // Check this contract's balance

        lastWithdraw = block.timestamp; // update state before transfer

        (bool sent, ) = msg.sender.call{value: amount}(""); // Sends Eth to deployer or fixedOwener
        require(sent, "Transfer failed"); // If Eth doesnt go through
    }

    // --- Fallback and receive functions to accept ETH ---
    receive() external payable {
        totalReceived += msg.value;
    }

    fallback() external payable {
        totalReceived += msg.value;
    }
}