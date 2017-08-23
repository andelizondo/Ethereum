pragma solidity ^0.4.15;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
	// Send _value amount of tokens to address _to
	function transfer(address _to, uint256 _value) returns (bool success);

	// Send _value amount of tokens from address _from to address _to
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

	// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
	// If this function is called again it overwrites the current allowance with _value.
	// this function is required for some DEX functionality
	function approve(address _spender, uint256 _value) returns (bool success);

	// Triggered when tokens are transferred.
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	// Triggered whenever approve(address _spender, uint256 _value) is called.
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}