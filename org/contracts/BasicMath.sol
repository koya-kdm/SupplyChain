pragma solidity ^0.4.24;

contract basicMath {
    uint256 constant private MAX_UINT256 = 2**256 - 1;

    function add(uint256 _numberA, uint256 _numberB) public pure returns(uint256) {
        require(_numberA + _numberB < MAX_UINT256,"Overflow");
        return _numberA + _numberB;
    }
}