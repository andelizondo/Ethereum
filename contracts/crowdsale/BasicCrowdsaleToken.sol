pragma solidity ^0.4.15;

import './TradeableToken.sol';
import './MintableToken.sol';

contract BasicCrowdsaleToken is Tradeable, Mintable {
	/* Initializes Token with its initial Tradeable properties */
	function BasicCrowdsaleToken(
	    uint256 _tokenPrice, uint256 _etherPrice
	) Tradeable (
		_tokenPrice, _etherPrice
	) {}
}
