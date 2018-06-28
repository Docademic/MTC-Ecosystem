pragma solidity ^0.4.21;

import "./ownership/MultiOwnable.sol";
import "./math/SafeMath.sol";
import "./util/Destroyable.sol";

interface Token {
	function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

contract BrokerImp is MultiOwnable, Destroyable {
	using SafeMath for uint256;
	
	Token public token;
	uint256 public commission;
	address public broker;
	address public pool;
	
	/**
	 * @dev Constructor.
	 * @param _token The token address
	 * @param _pool The pool of tokens address
	 * @param _commission The percentage of the commission 0-100
	 * @param _broker The broker address
	 */
	constructor (address _token, address _pool, uint256 _commission, address _broker) public {
		require(_token != address(0));
		token = Token(_token);
		pool = _pool;
		commission = _commission;
		broker = _broker;
	}
	
	/**
	 * @dev Allows the owner make a reward.
	 * @param _beneficiary the beneficiary address
	 * @param _value the tokens reward in wei
	 */
	function reward(address _beneficiary, uint256 _value) public returns (bool){
		uint256 beneficiaryPart = uint256(100).sub(commission);
		uint256 hundred = uint256(100);
		uint256 total = _value.div(beneficiaryPart.div(hundred));
		uint256 brokerCommission = total.mul(commission.div(hundred));
		return (
		token.transferFrom(pool, _beneficiary, _value) &&
		token.transferFrom(pool, broker, brokerCommission)
		);
	}
}
