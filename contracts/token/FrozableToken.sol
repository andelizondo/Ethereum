pragma solidity ^0.4.15;

import './BasicToken.sol';

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
		require (_to != 0x0);								// Prevent transfer to 0x0 address. Use burn() instead
		require (balanceOf[_from] >= _value);				// Check if the sender has enough
		require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
		require (!frozenAccount[_from]);					// Check that both accounts
		require (!frozenAccount[_to]);						// are not currently frozen
		balanceOf[_from] -= _value;							// Subtract from the sender
		balanceOf[_to] += _value;							// Add the same to the recipient
		Transfer(_from, _to, _value);						// Notify anyone listening that this transfer took place
	}
}
