pragma solidity ^0.4.13;

contract HumanReadable {
	/* Human-readable properties of the token */
	string public version = '0.1';
	string public name = 'IterToken';
	string public symbol = 'ITR';
	uint8 public decimals = 3;
	uint256 public totalSupply = 21000000000;
}

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

contract Owned {
	// Account / Address that owns the contract
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

contract Disposable is Owned {
	function kill() onlyOwner {
		selfdestruct(owner);
	}
}

contract Token is HumanReadable, ERC20, Owned, Frozable, Disposable {
	/* This creates an array with all balances and (spent) allowances */
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;
	
	/* Initializes contract with initial supply tokens to the creator of the contract */
	function Token() {
		balanceOf[msg.sender] = totalSupply;				// Give the creator all initial tokens
	}

	/* Internal transfer, only can be called by this contract */
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

contract Mintable is Token {
	/* This notifies clients about the amount burnt */
	event Mint(address indexed from, uint256 value);

	/* Creates more token supply and sends it to the specified account */
	function mintToken(uint256 _value) onlyOwner returns (bool success) {
		require (balanceOf[owner] + _value > balanceOf[owner]); // Check for overflows
		require (totalSupply + _value > totalSupply);			// also in the totalSupply
		balanceOf[owner] += _value;						// Add to the owner
		totalSupply += _value;							// Updates totalSupply
		Mint(owner, _value);
		return true;
	}
}

contract Burnable is Token {
	/* This notifies clients about the amount burnt */
	event Burn(address indexed from, uint256 value);

	/// @notice Remove `_value` tokens from the system irreversibly
	/// @param _value the amount of money to burn
	function burn(uint256 _value) onlyOwner returns (bool success) {
		require (balanceOf[owner] >= _value);			 // Check if the sender has enough
		balanceOf[owner] -= _value;						 // Subtract from the owner
		totalSupply -= _value;							 // Updates totalSupply
		Burn(owner, _value);
		return true;
	}
}

contract Tradeable is Token {
	/* Public variables of the eth/token price */
	uint256 public tokenPrice = 2121;
	uint256 public etherPrice = 268630;
	uint256 public oneTokenInWei = 1 ether * tokenPrice / etherPrice;

	/* Sets the price for which the tokes can be bought (ETH/TKN) */
	function updatePrices(uint256 _newTokenPrice, uint _newEtherPrice) onlyOwner {
		tokenPrice = _newTokenPrice;
		etherPrice = _newEtherPrice;
		oneTokenInWei = 1 ether * tokenPrice / etherPrice;
	}

	/* Buys tokens with Eth at current Token price */
	function buy() payable returns (uint256 amount) {
		amount = (msg.value * (10 ** uint256(decimals))) / oneTokenInWei;		// calculates the amount
		_transfer(owner, msg.sender, amount);				// Transfer the amount from the owner to the sender
		return amount;										// ends function and returns
	}

	/* Sells tokens for Eth at current Token price */
	function sell(uint256 _amount) returns (uint256 revenue) {
		_transfer(msg.sender, owner, _amount);				  // Transfer the amount from the sender to the owner
		revenue = _amount * oneTokenInWei / (10 ** uint256(decimals));
		if (!msg.sender.send(revenue)) {
		  revert();
		} else {
		  return revenue;									// ends function and returns
		}
	}
}

contract IterToken is Token, Tradeable, Mintable, Burnable {
	/* This unnamed function is called whenever someone tries to send ether to it */
	function() {
		revert();	// Prevents accidental sending of ether
	}
}
