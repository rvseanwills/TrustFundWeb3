/*

• it should be able to accept SepETH (the currency for the Sepolia testnet) from anyone;
• it should allow SepETH to be retrieved only by the following addresses:
– 0x3cC92b7496571fC479EB4714784a6839CD3e57f2
– your own address from which the contract is deployed
• not more than 1 SepETH can be retrieved at a time; and
• after a retrieval, the funds are locked for 30 minutes for all addresses.

/*
Successful deployment of your contract on the Sepolia testnet, evidenced by the transaction hash
searchable on Etherscan. (5 marks)
2. The contract should be able to accept SepETH at its own address. (10 marks) - 
    https://dev.to/emanuelferreira/how-to-create-a-smart-contract-to-receive-donations-using-solidity-4k8
    https://dev.to/xvishere/how-eth-is-received-in-smart-contracts-2khk
3. The contract should allow retrieval of SepETH. (5 marks)
    https://dev.to/tchisom17/understanding-ether-transfers-in-solidity-send-transfer-and-call-3k67
4. Only the two accounts specified above can retrieve SepETH from the contract. (5 marks)
5. Retrieval of SepETH should be able to be done once per 30 min with a maximum value of 1 SepETH.
(10 marks)
6. Your contract should be re-entrancy attack resistant. (10 marks)
7. Code quality - it should be well commented, and without obvious security vulnerabilities. (5 marks)
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract TrustFund {
    uint totalRecieved; 
    address immutable immutableOwner;
    address mutableOwner;
    uint lastWithdraw;

    constructor (address _mutableOwner) {
        immutableOwner = msg.sender;
        mutableOwner = _mutableOwner;
        lastWithdraw = block.timestamp;
    }

    modifier checkOwner() {
        require (msg.sender == immutableOwner || msg.sender == mutableOwner, "Failed Owner Check.");
        _;
    }

    function withdraw() public payable checkOwner {
        // Max 1 SepETH and Min 30 mins since last Withdraw
        uint stamp = block.timestamp;
        require (msg.value <= 1, "Value requested over 1.");
        require ((lastWithdraw >= stamp ? lastWithdraw - stamp : stamp - lastWithdraw) <= 1800, "30 Minutes has not elapsed since the last withdraw." ); // basically: Math.Abs(previous, current) <= 30 mins
        (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether to Owner");
     }

    function getTotalRecieved() view public returns(uint) {
        return totalRecieved;
    }

    // Deposit Function
    function deposit() public payable {
        totalRecieved += msg.value;
    }
    // Deposit Function (no call data)
    receive() external payable {
        totalRecieved += msg.value;
    }
    // Deposit Function (with call data, but no recognized signature)
    fallback() external payable { 
        totalRecieved += msg.value;
    }
    
}