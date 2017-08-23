pragma solidity ^0.4.15;

import './OwnedToken.sol';

contract Disposable is Owned {
	function kill() onlyOwner {
		selfdestruct(owner);
	}
}