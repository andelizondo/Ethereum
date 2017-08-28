pragma solidity ^0.4.15;

contract Ownable {
	// Makes the token ownable to provide security features

	// Account-Address that owns the contract
	address public owner;

	/* This notifies clients about a change of ownership */
	event OwnershipChange(address indexed _owner);

	// Initializes the contract and sets the owner to the contract creator
	function Ownable() {
		owner = msg.sender;
	}

	// This modifier is used to execute functions only by the owner of the contract
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	// Transfers the ownership of the contract to another address
	function transferOwnership(address _newOwner) onlyOwner returns (bool success) {
		owner = _newOwner;
		OwnershipChange(owner);
		return true;
	}
}
