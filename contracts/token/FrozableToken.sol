pragma solidity ^0.4.15;

import './OwnedToken.sol';

contract Frozable is Owned {
	mapping (address => bool) public frozenAccount;

	/* This notifies clients about the account frozen */
	event FrozenFunds(address indexed target, bool frozen);

	/* Frozes an account to disable transfers */
	function freezeAccount(address _target, bool _freeze) onlyOwner {
		frozenAccount[_target] = _freeze;
		FrozenFunds(_target, _freeze);
	}
}