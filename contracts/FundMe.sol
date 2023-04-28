//get funds from users

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./PriceConverter.sol"; //importing the library of functions.

contract FundMe2 {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 1e18;

    address[] public funders; // address array to store all the addresses of the funders.
    mapping(address => uint256) public addressToAmountFunded;

    address public owner; // to store the address of the one who first deploys this contract.

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        // a contructor is something that is called right when you deploy the contract.
        owner = msg.sender; // address stored.
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    modifier onlyOwner() {
        // we can put this in function declaration where we need this condition to be satisfied.
        require(msg.sender == owner, "Sender is not owner!");
        _; //underscore signal only to do the rest of the code if this modifier code is satisfied
        //if underscore was above the require code, then the function code is done before the modifier code is run.
    }

    function fund() public payable {
        //smart contract addresses can hold funds just like wallets.
        require(
            msg.value.getConversionRate(priceFeed) >= minimumUsd, //takes two parameters, first parameter is msg.value and the second one is priceFeed
            "did'nt send enough!"
        ); //since we are using the library function.
        //msg.value is considered as the first parameter for any of these library functions.
        //We want to set a minimum fund amount in usd
        //require(getConversionRate(msg.value) >= minimumUsd, "Did'nt send enough!"); // 1e18 = 1 * 10 ** 18 = 1 eth, since 1e18 wei is 1 eth
        // revert undos any action before and sends the remaining gas back, so if not enough ether is send, this will revert.
        funders.push(msg.sender); // msg.sender gives address of whoever calls the fund function.
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        // modifier used.
        //require(msg.sender == owner, "sender is not owner!"); //only the owner can withdraw funds - we will create a modifier for this
        //1.set the addresstoamountfunded to zero
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            //starting index, ending, change per loop
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;

            //2. reset the funders array
            funders = new address[](0); //we set a new address array with zero objects.
            //3.actually withdraw the funds
            //three different ways- transfer, send, call.

            //transfer

            // payable(msg.sender).transfer(address(this).balance);//msg.sender is type address so we type cast it to payable address type.
            // //msg.sender is the address to which we send the balance.
            // //if transfer fails, it would show error and revert the transaction
            // bool sendSuccess = payable(msg.sender).send(address(this).balance);
            // require(sendSuccess, "send failed");
            // //send does not show error instead returns true or false
            // //so we add requre statement to revert it if it fails

            (bool callSuccess, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
            //returns two varibles, quite advanced function, will learn more later.
            require(callSuccess, "Call failed!");
        }
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
