pragma solidity ^0.4.15;

import './TradeableToken.sol';
import './MintableToken.sol';
import './Disposable.sol';

contract BasicCrowdsaleToken is Tradeable, Mintable, Disposable {
	/* Initializes Token with its initial Tradeable properties */
	function BasicCrowdsaleToken(
	    uint256 _tokenPrice, uint256 _etherPrice
	) Tradeable (
		_tokenPrice, _etherPrice
	) {}
}
