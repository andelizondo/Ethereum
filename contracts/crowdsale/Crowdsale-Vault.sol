pragma solidity ^0.4.15;

import './Utils-Ownable.sol';
import './Utils-Disposable.sol';

/**
* @title RefundVault
* @dev This contract is used for storing funds while a crowdsale
* is in progress. Supports refunding the money if crowdsale fails,
* and forwarding it if crowdsale is successful.
*/
contract CrowdsaleVault is Ownable, Disposable {
    enum State { Active, Refunding, Closed }

    State public state;
    address public wallet;
    mapping (address => uint256) public deposited;

    event RefundsEnabled();
    event Withdraw(address indexed _beneficiary, uint256 _amount);
    event Refund(address indexed _beneficiary, uint256 _amount);

    function CrowdsaleVault(address _wallet) {
        require(_wallet != 0x0);
        wallet = _wallet;
        state = State.Active;
    }

    function deposit(address _investor) onlyOwner payable {
        require(state == State.Active);
        deposited[_investor] += msg.value;
    }

    function enableRefunds() onlyOwner {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address _investor) onlyOwner {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[_investor];
        require(depositedValue > 0);
        deposited[_investor] = 0;
        _investor.transfer(depositedValue);
        Refund(_investor, depositedValue);
    }

    function withdraw() onlyOwner {
        require(state == State.Active);
        state = State.Closed;
        wallet.transfer(this.balance);
        Withdraw(wallet, this.balance);
    }
}
