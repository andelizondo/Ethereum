pragma solidity ^0.4.15;

// Makes the token ownable and provides security features 
contract Owned {
	// Account-Address that owns the contract
	address public owner;

	// Initializes the contract and sets the owner to the contract creator
	function Owned() {
		owner = msg.sender;
	}

	// This modifier is used to execute functions only by the owner of the contract
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	// Transfers the ownership of the contract to another address
	function transferOwnership(address _newOwner) onlyOwner {
		owner = _newOwner;
	}
}