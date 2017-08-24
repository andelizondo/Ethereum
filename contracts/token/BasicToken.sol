pragma solidity ^0.4.15;

import './ERC20Token.sol';
import './OwnableToken.sol';

contract Token is ERC20, Ownable {
	/* Initializes contract with initial supply tokens to the creator of the contract */
	function Token(
		string _version,
		string _name,
		string _symbol,
		uint8  _decimals,
		uint256 _totalSupply
		) {
		version = _version;									// Set the version for display purposes
		name = _name;                                   	// Set the name for display purposes
		symbol = _symbol;                               	// Set the symbol for display purposes
		decimals = _decimals;                           	// Amount of decimals for display purposes
		totalSupply = _totalSupply;                        	// Update total supply
		balanceOf[msg.sender] = totalSupply;              	// Give the creator all initial tokens
	}

	/* Internal transfer, only can be called by this or inherited contracts  */
	function _transfer(address _from, address _to, uint _value) internal {
		require (_to != 0x0);								// Prevent transfer to 0x0 address. Use burn() instead
		require (balanceOf[_from] >= _value);				// Check if the sender has enough
		require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
		balanceOf[_from] -= _value;							// Subtract from the sender
		balanceOf[_to] += _value;							// Add the same to the recipient
		Transfer(_from, _to, _value);						// Notify anyone listening that this transfer took place
	}

	/// @notice Send `_value` tokens to `_to` from your account
	/// @param _to The address of the recipient
	/// @param _value the amount to send
	function transfer(address _to, uint256 _value) returns (bool success) {
		_transfer(msg.sender, _to, _value);
		return true;
	}

	/// @notice Send `_value` tokens to `_to` in behalf of `_from`
	/// @param _from The address of the sender
	/// @param _to The address of the recipient
	/// @param _value the amount to send
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
		require (_value <= allowance[_from][msg.sender]);	  // Check allowance
		allowance[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		return true;
	}

	/// @notice Allows `_spender` to spend no more than `_value` tokens in your behalf
	/// @param _spender The address authorized to spend
	/// @param _value the max amount they can spend
	function approve(address _spender, uint256 _value) returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}
}
