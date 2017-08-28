pragma solidity ^0.4.15;

import './BasicToken.sol';

contract Mintable is Token {
    bool public mintingEnabled = true;

    /** List of agents that are allowed to create new tokens */
    mapping (address => bool) public mintAgents;

	/* This notifies clients about the amount minted */
	event Mint(address indexed _from, uint256 _value);
	event MintDisabled(address indexed _from);
    event MintingAgent(address indexed _agentAddress, bool _approved);

    // Initializes the contract and sets the owner as minting agent
	function Mintable() {
		mintAgents[owner] = true;
	}

	/* Creates more token supply and sends it to the specified account */
	function mint(address _receiver, uint256 _value) onlyMintAgent canMint returns (bool success) {
		require (balanceOf[_receiver] + _value > balanceOf[_receiver]); // Check for overflows
		require (totalSupply + _value > totalSupply);			        // also in the totalSupply
		balanceOf[_receiver] += _value;						            // Add to the _receiver
		totalSupply += _value;							                // Updates totalSupply

        // This will make the mint transaction apper in EtherScan.io
        // We can remove this after there is a standardized minting event
		Mint(_receiver, _value);
        Transfer(msg.sender, _receiver, _value);
		return true;
	}

	// Owner can allow a crowdsale contract to mint new tokens.
    function approveMintAgent(address _agentAddress, bool _approved) onlyOwner canMint {
        mintAgents[_agentAddress] = _approved;
        MintingAgent(_agentAddress, _approved);
    }

    // Owner can disable minting of new tokens
    function disableMinting() onlyOwner {
        mintingEnabled = false;
        MintDisabled(owner);
    }

    // Only crowdsale contracts are allowed to mint new tokens
    modifier onlyMintAgent() {
        require (mintAgents[msg.sender]);
        _;
    }
    // Make sure minting is still possible.
    modifier canMint() {
        require (mintingEnabled);
        _;
    }

}
