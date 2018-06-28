pragma solidity ^0.4.21;

import "./ownership/Ownable.sol";
import "./math/SafeMath.sol";
import "./util/Destroyable.sol";

interface Token {
	function balanceOf(address who) view external returns (uint256);
	
	function allowance(address _owner, address _spender) view external returns (uint256);
	
	function transfer(address _to, uint256 _value) external returns (bool);
	
	function approve(address _spender, uint256 _value) external returns (bool);
	
	function increaseApproval(address _spender, uint256 _addedValue) external returns (bool);
	
	function decreaseApproval(address _spender, uint256 _subtractedValue) external returns (bool);
}

contract TokenPool is Ownable, Destroyable {
	using SafeMath for uint256;
	
	Token public token;
	address public spender;
	
	/**
	 * @dev Constructor.
	 * @param _token The token address
	 */
	constructor(address _token, address _spender) public{
		require(_token != address(0) && _spender != address(0));
		token = Token(_token);
		spender = spender;
	}
	
	/**
	 * @dev Get the token balance of the contract.
	 * @return _balance The token balance of this contract in wei
	 */
	function Balance() view public returns (uint256 _balance) {
		return token.balanceOf(address(this));
	}
	
	/**
	 * @dev Allows the owner to set up the allowance to the spender.
	 */
	function setUpAllowance() public onlyOwner {
		token.approve(spender, token.balanceOf(address(this)));
	}
	
	/**
	 * @dev Allows the owner to update the allowance of the spender.
	 */
	function updateAllowance() public onlyOwner {
		uint256 balance = token.balanceOf(address(this));
		uint256 allowance = token.allowance(address(this), spender);
		uint256 difference = balance.sub(allowance);
		token.increaseApproval(spender, difference);
	}
	
	/**
	 * @dev Allows the owner to destroy the contract and return the tokens to the owner.
	 */
	function destroy() public onlyOwner {
		token.transfer(owner, token.balanceOf(address(this)));
		selfdestruct(owner);
	}
	
}
