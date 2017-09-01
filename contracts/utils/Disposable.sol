pragma solidity ^0.4.15;

import './Ownable.sol';

contract Disposable is Ownable {
	// This notifies clients about the self destruction of the contract
	// and which account got the remaining balance on the contract
	event Dispose(address indexed _owner, uint256 _value);

	function dispose() onlyOwner {
		Dispose(owner, this.balance);
		selfdestruct(owner);
	}
}
