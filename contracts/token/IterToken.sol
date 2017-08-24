pragma solidity ^0.4.15;

import './BasicToken.sol';
import './TradeableToken.sol';
import './MintableToken.sol';
import './BurnableToken.sol';
import './FrozableToken.sol';
import './DisposableToken.sol';

contract IterToken is Token, Tradeable, Mintable, Burnable, Frozable, Disposable {
	// Basic Token Properties
	string private _version = '0.1';
	string private _name = 'IterToken';
	string private _symbol = 'ITR';
	uint8  private _decimals = 3;
	uint256 private _totalSupply = 21000000000;

	// Tradeable Token Properties
	uint256 _tokenPrice = 2121;
	uint256 _etherPrice = 268630;

	/* Initializes contract with its initial Basic and Tradeable properties */
	function IterToken(
	) Token (
		_version, _name, _symbol, _decimals, _totalSupply
	) Tradeable (
		_tokenPrice, _etherPrice
	) {}

	/* This unnamed function is called whenever someone tries to send ether to the contract */
	function() {
		revert();	// Prevents accidental sending of ether
	}
}
