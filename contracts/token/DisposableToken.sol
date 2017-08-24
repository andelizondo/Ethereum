pragma solidity ^0.4.15;

import './BasicToken.sol';

contract Disposable is Token {
	// This notifies clients about the self destruction of the contract
	// and which account got the remaining balance on the contract
	event Dispose(address indexed _owner, uint256 _value);

	function kill() onlyOwner {
		Dispose(owner, this.balance);
		selfdestruct(owner);
	}
}
