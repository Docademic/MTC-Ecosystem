pragma solidity ^0.4.21;

import "./ownership/Ownable.sol";
import "./math/SafeMath.sol";
import "./util/Destroyable.sol";

interface Token {
	function balanceOf(address who) view external returns (uint256);
	
	function transfer(address _to, uint256 _value) external returns (bool);
}

contract BrokerBank is Ownable, Destroyable {
	using SafeMath for uint256;
	
	Token public token;
	uint256 public commission;
	address public broker;
	address public beneficiary;
	
	event CommissionChanged(uint256 _previousCommission, uint256 _commision);
	event BrokerChanged(address _previousBroker, address _broker);
	event BeneficiaryChanged(address _previousBeneficiary, address _beneficiary);
	event Withdrawn(uint256 _balance);
	
	/**
	 * @dev Constructor.
	 * @param _token The token address
	 * @param _commission The percentage of the commission 0-100
	 * @param _broker The broker address
	 * @param _beneficiary The beneficiary address
	 */
	constructor (address _token, uint256 _commission, address _broker, address _beneficiary) public {
		require(_token != address(0));
		token = Token(_token);
		commission = _commission * 1 ether;
		broker = _broker;
		beneficiary = _beneficiary;
	}
	
	/**
	 * @dev Get the token balance of the contract.
	 * @return _balance The token balance of this contract in wei
	 */
	function Balance() view public returns (uint256 _balance) {
		return token.balanceOf(address(this));
	}
	
	/**
	 * @dev Allows the owner to destroy the contract and return the tokens to the owner.
	 */
	function destroy() public onlyOwner {
		token.transfer(owner, token.balanceOf(address(this)));
		selfdestruct(owner);
	}
	
	/**
	 * @dev Allows the owner to withdraw the token funds.
	 */
	function withdraw() public onlyOwner {
		uint256 balance = token.balanceOf(address(this));
		uint256 hundred = 100 * 1 ether;
		uint256 brokerWithdraw = balance.mul(commission.div(hundred));
		uint256 beneficiaryWithdraw = balance.sub(brokerWithdraw);
		token.transfer(beneficiary, beneficiaryWithdraw);
		token.transfer(broker, brokerWithdraw);
		emit Withdrawn(balance);
	}
	
	/**
	 * @dev Allows the owner to withdraw the balance of the tokens.
	 * @param _commission The percentage of the commission 0-100
	 */
	function changeCommission(uint256 _commission) public onlyOwner {
		emit CommissionChanged(commission, _commission);
		commission = _commission * 1 ether;
	}
	
	/**
	 * @dev Allows the owner to change the broker.
	 * @param _broker The broker address
	 */
	function changeBroker(address _broker) public onlyOwner {
		emit BrokerChanged(broker, _broker);
		broker = _broker;
	}
	
	/**
	 * @dev Allows the owner to change the beneficiary.
	 * @param _beneficiary The broker address
	 */
	function changeBeneficiary(address _beneficiary) public onlyOwner {
		emit BeneficiaryChanged(beneficiary, _beneficiary);
		beneficiary = _beneficiary;
	}
}
