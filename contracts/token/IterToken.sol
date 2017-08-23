pragma solidity ^0.4.15;

import './BasicToken.sol';
import './TradeableToken.sol';
import './MintableToken.sol';
import './BurnableToken.sol';

contract IterToken is Token, Tradeable, Mintable, Burnable {

	/* Initializes the contract with the initial properties of the Token */
    function IterToken () {
        /* Sets the Human-Readable Properties of the Token */
    	version = '0.2';
    	name = 'IterToken';
    	symbol = 'ITR';
    	decimals = 3;
    	totalSupply = 21000000000;
    	
    	/* Sets the Tradeable Properties of the Token */
    	tokenPrice = 2121;
    	etherPrice = 268630;
    	_setTokenWeiPrice();
    }

	/* This unnamed function is called whenever someone tries to send ether to it */
	function() {
		revert();	// Prevents accidental sending of ether
	}
}
