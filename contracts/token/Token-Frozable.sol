pragma solidity ^0.4.15;

import './Token-Basic.sol';

contract Frozable is Token {
	mapping (address => bool) public frozenAccount;

	/* This notifies clients about the account frozen */
	event FrozenFunds(address indexed _target, bool _frozen);

	/* Frozes an account to disable transfers */
	function freezeAccount(address _target, bool _freeze) onlyOwner returns (bool success) {
		frozenAccount[_target] = _freeze;
		FrozenFunds(_target, _freeze);
		return true;
	}

	// Overrides the internal _transfer function with Frozable attributes
	function _transfer(address _from, address _to, uint _value) internal {
		require (!frozenAccount[_from]);					// Check that both accounts
		require (!frozenAccount[_to]);						// are not currently frozen
		super._transfer(_from, _to, _value);                // Performs the normal transfer from Basic Token
	}
}
