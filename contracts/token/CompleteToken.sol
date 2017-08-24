pragma solidity ^0.4.13;

contract HumanReadable {
	// Human-readable properties of the token
	string internal version;
	string public name;
	string public symbol;
	uint8 public decimals;
}

contract ERC20 is HumanReadable {
	// ERC Token Standard #20 Interface
	// https://github.com/ethereum/EIPs/issues/20

	// Get the total token supply
	uint256 public totalSupply;

	// Get the account balance of an account
	mapping (address => uint256) public balanceOf;

	// Returns the amount which _spender is still allowed to withdraw from _owner
	mapping (address => mapping (address => uint256)) public allowance;

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

contract Mintable is Token {
	/* This notifies clients about the amount minted */
	event Mint(address indexed _from, uint256 _value);

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
	event Burn(address indexed _from, uint256 _value);

	/// @notice Remove `_value` tokens from the system irreversibly
	/// @param _value the amount of money to burn
	function burn(uint256 _value) onlyOwner returns (bool success) {
		require (balanceOf[owner] >= _value);			 // Check if the sender has enough
		require (totalSupply - _value >= 0); 			 // Check if there's enough supply
		balanceOf[owner] -= _value;						 // Subtract from the owner
		totalSupply -= _value;							 // Updates totalSupply
		Burn(owner, _value);
		return true;
	}
}

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

contract Disposable is Token {
	// This notifies clients about the self destruction of the contract
	// and which account got the remaining balance on the contract
	event Dispose(address indexed _owner, uint256 _value);

	function kill() onlyOwner {
		Dispose(owner, this.balance);
		selfdestruct(owner);
	}
}

contract Tradeable is Token {
	/* Public variables of the eth/token price */
	uint256 public tokenPrice;
	uint256 public etherPrice;
	uint256 private oneTokenInWei;

	/* This notifies clients about the account frozen */
	event PriceUpdate(address indexed _owner, uint256 _tokenPrice, uint256 _etherPrice, uint256 _oneTokenInWei);

	/* Initializes contract with the provided prices */
	function Tradeable(uint256 _tokenPrice, uint256 _etherPrice) {
		updatePrices(_tokenPrice, _etherPrice);
	}

	/* Sets the price for which the tokes can be bought (ETH/TKN) */
	function updatePrices(uint256 _tokenPrice, uint256 _etherPrice) onlyOwner {
		tokenPrice = _tokenPrice;
		etherPrice = _etherPrice;
		_setTokenWeiPrice();
		PriceUpdate(msg.sender, tokenPrice, etherPrice, oneTokenInWei);
	}

	/* Internal transfer, only can be called by this contract */
	function _setTokenWeiPrice() internal {
		oneTokenInWei = 1 ether * tokenPrice / etherPrice;
	}

	/* Buys tokens with Eth at current Token price */
	function buy() payable returns (uint256 amount) {
		amount = (msg.value * (10 ** uint256(decimals))) / oneTokenInWei;	// calculates the amount of tokens to send
		_transfer(owner, msg.sender, amount);				// Transfer the amount from the owner to the sender
		return amount;										// ends function and returns
	}

	/* Sells tokens for Eth at current Token price */
	function sell(uint256 _amount) returns (uint256 revenue) {
		revenue = _amount * oneTokenInWei / (10 ** uint256(decimals));		// calculates the amount of eth to send
		require(this.balance >= revenue);    				// checks if the contract has enough ether to buy the tokens
		_transfer(msg.sender, owner, _amount);				// Transfer the amount from the sender to the owner
		msg.sender.transfer(revenue);     					// sends ether to the seller. It's important to do this last to avoid recursion attacks
		return revenue;
	}
}

contract IterToken is Token, Tradeable, Mintable, Burnable, Frozable, Disposable {
	// Basic Token Properties
	string private _version = '0.1';
	string private _name = 'IterToken';
	string private _symbol = 'ITR';
	uint8  private _decimals = 3;
	uint256 private _totalSupply = 21000000000;

	// Tradeable Token Properties
	uint256 _tokenPrice = 2121;
	uint256 _etherPrice = 268630;

	/* Initializes contract with its initial Basic and Tradeable properties */
	function IterToken(
	) Token (
		_version, _name, _symbol, _decimals, _totalSupply
	) Tradeable (
		_tokenPrice, _etherPrice
	) {}

	/* This unnamed function is called whenever someone tries to send ether to the contract */
	function() {
		revert();	// Prevents accidental sending of ether
	}
}
