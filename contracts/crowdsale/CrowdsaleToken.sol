pragma solidity ^0.4.15;

import './BasicToken.sol';
import './TradeableToken.sol';
import './MintableToken.sol';
import './BurnableToken.sol';
import './FrozableToken.sol';
import './Disposable.sol';

contract CrowdsaleToken is Token, Tradeable, Mintable, Burnable, Frozable, Disposable {
	// Basic Token Properties
	string private _version = '0.1';
	string private _name = 'Fiets';
	string private _symbol = hex"F09F9AB2";
	uint8  private _decimals = 0;
	uint256 private _totalSupply = 100;

	// Tradeable Token Properties
	uint256 _tokenPrice = 210;
	uint256 _etherPrice = 270;

	/* Initializes contract with its initial Basic and Tradeable properties */
	function CrowdsaleToken(
	) Token (
		_version, _name, _symbol, _decimals, _totalSupply
	) Tradeable (
		_tokenPrice, _etherPrice
	) {}

	/* This unnamed function is called whenever someone tries to send ether to the contract */
	function () payable {
        buy();
    }
}
