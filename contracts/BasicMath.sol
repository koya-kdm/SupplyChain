pragma solidity ^0.4.24;

contract basicMath {
    uint256 constant private MAX_UINT256 = 2**256 - 1;

        require(_numberA + _numberB < MAX_UINT256,"Overflow");
        return _numberA + _numberB;
    }
}