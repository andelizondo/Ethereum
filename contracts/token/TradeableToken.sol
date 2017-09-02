pragma solidity ^0.4.15;

import './BasicToken.sol';

contract Tradeable is Token {
	/* Public variables of the eth/token price */
	uint256 public tokenPrice;
	uint256 public etherPrice;

	/* This notifies clients about the account frozen */
	event PriceUpdate(address indexed _owner, uint256 _tokenPrice, uint256 _etherPrice, uint256 _oneTokenInWei);

	/* Initializes contract with the provided prices */
	function Tradeable(uint256 _tokenPrice, uint256 _etherPrice) {
		tokenPrice = _tokenPrice;
		etherPrice = _etherPrice;
	}

	/* Sets the price for which the tokes can be bought (ETH/TKN) */
	function updatePrices(uint256 _tokenPrice, uint256 _etherPrice) onlyOwner {
		tokenPrice = _tokenPrice;
		etherPrice = _etherPrice;
		PriceUpdate(msg.sender, tokenPrice, etherPrice, tokenPriceInWei());
	}

	// @return the price of the token in Wei according to the current exchange prices
    function tokenPriceInWei() constant returns (uint256) {
        return 1 ether * tokenPrice / etherPrice;
    }

	/* Buys tokens with Eth at current Token price */
	function buy() payable returns (uint256 amount) {
		amount = amountOfTokensToBuy(msg.value);			// calculates the amount of tokens to send
		_transfer(owner, msg.sender, amount);				// Transfer the amount from the owner to the sender

		var change = msg.value - valueOfTokensToSell(amount);
		msg.sender.transfer(change);     					// returns change to the sender.
		return amount;										// ends function and returns
	}
	function amountOfTokensToBuy(uint256 _valueInWei) constant returns (uint256 amount) {
		return (_valueInWei * (10 ** uint256(decimals))) / tokenPriceInWei();
	}

	/* Sells tokens for Eth at current Token price */
	function sell(uint256 _amount) returns (uint256 value) {
		value = valueOfTokensToSell(_amount);				// calculates the amount of eth to send
		require(this.balance >= value);    					// checks if the contract has enough ether to buy the tokens
		_transfer(msg.sender, owner, _amount);				// Transfer the amount from the sender to the owner
		msg.sender.transfer(value);     					// sends ether to the seller. It's important to do this last to avoid recursion attacks
		return value;
	}
	function valueOfTokensToSell(uint256 _amount) constant returns (uint256 valueInWei) {
		return _amount * tokenPriceInWei() / (10 ** uint256(decimals));
	}
}
