//SPDX-License-Identifier: MIT
//this is actually going to be a library.
//cant have state variables and cant send any ether.
//all the functions in a library is going to be internal

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//use yarn add --dev @chainlink/contracts
library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // since we have to interact with a contract outside of this project
        //we will need the ABI and the address of the chainlink contract to get the price.
        // address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //to get address go to ethereum data feeds.
        //to get the abi, we use interfaces, interfaces are programs which have all the functions of the contract we need
        //but has no code of the functions, since abi is just a list of functions in a contract, we can use that interface.
        //https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
        //check this interface out that we will be using.
        //we can either copy paste this interface here or import the npm link which we got from chainlink docs

        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        (, int256 price, , , ) = priceFeed.latestRoundData(); //since latestrounddata returns multiple values, look in code.
        return uint256(price); //multiply to match msg.value units in wei
    }

    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; //always multiply first.
        return ethAmountInUsd;
    }
}
