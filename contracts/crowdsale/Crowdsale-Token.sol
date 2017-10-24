pragma solidity ^0.4.15;

import './Token-Tradeable.sol';
import './Token-Mintable.sol';
import './Token-Burnable.sol';
import './Token-Frozable.sol';
import './Utils-Disposable.sol';

contract CrowdsaleToken is Token, Tradeable, Mintable, Burnable, Frozable, Disposable {

	/* Initializes contract with its initial Token values, and its Basic and Crowdsale properties */
	function CrowdsaleToken(
		string _version, string _name, string _symbol, uint8  _decimals, uint256 _totalSupply,
		uint256 _tokenPrice, uint256 _etherPrice
	) Token (
		_version, _name, _symbol, _decimals, _totalSupply
	) Tradeable (
		_tokenPrice, _etherPrice
	) {}

	/* This unnamed function is called whenever someone tries to send ether to the contract */
	function () payable {
        buy();
    }

	// TODO: This could be implemented within an Transferable contract
    // Overrides ownership transfer to also give all tokens to crowdsale owner
	function transferOwnership(address _newOwner) onlyOwner returns (bool success) {
		if(balanceOf[owner] > 0){
			_transfer(owner, _newOwner, balanceOf[owner]);
		}
		return super.transferOwnership(_newOwner);
	}
}
