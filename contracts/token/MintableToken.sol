pragma solidity ^0.4.15;

import './BasicToken.sol';

contract Mintable is Token {
	/* This notifies clients about the amount burnt */
	event Mint(address indexed from, uint256 value);

	/* Creates more token supply and sends it to the specified account */
	function mintToken(uint256 _value) onlyOwner returns (bool success) {
		require (balanceOf[owner] + _value > balanceOf[owner]); // Check for overflows
		require (totalSupply + _value > totalSupply);			// also in the totalSupply
		balanceOf[owner] += _value;						// Add to the owner
		totalSupply += _value;							// Updates totalSupply
		Mint(owner, _value);
		return true;
	}
}