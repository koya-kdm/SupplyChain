// ----------------------------------------------------------------------------
///Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------

pragma solidity ^0.4.24;

import "./erc20Interface.sol";

contract ERC20Token is ERC20Interface {

    uint256 constant private MAX_UINT256 = 2 ** 256 - 1;

    // balances[アドレス] => 保有するトークン量
    mapping (address => uint256) public balances;

    // allowed[owner][spender] => 転送が許されたトークン量
    mapping (address => mapping (address => uint256)) public allowed;

    uint256 public totalSupply;  // トークン総数
    string  public name;         // トークン名称 (i.e. For Dummies Sample Token)
    uint8   public decimals;     // 表示する小数の桁数
    string  public symbol;       // トークンシンボル (i.e. FDT)

    // -------------------------------------------------------------------------
    // Create the new token and assign initial values, including initial amount
    // -------------------------------------------------------------------------
    constructor(uint256 _initialAmount,
                string  _tokenName,
                uint8   _decimalUnits,
                string  _tokenSymbol)
                public
    {
        balances[msg.sender] = _initialAmount;  // The creator owns all initial tokens
        totalSupply          = _initialAmount;  // Update total token supply
        name                 = _tokenName;      // Store the token name (used for display only)
        decimals             = _decimalUnits;   // Store the number of decimals (used for display only)
        symbol               = _tokenSymbol;    // Store the token symbol (used for display only)
    }

    // -------------------------------------------------------------------------
    // Transfer tokens from msg.sender to a specified address
    // -------------------------------------------------------------------------
    function transfer(address _to,
                      uint256 _value)
                      public
                      returns (bool success)
    {
        require(_value >= 0,"Cannot transfer negative amount.");
        require(balances[msg.sender] >= _value,"Insufficient funds for transfer source.");

        balances[msg.sender] -= _value;
        balances[_to       ] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    // -------------------------------------------------------------------------
    // Transfer tokens from one specified address to another specified address
    // -------------------------------------------------------------------------
    function transferFrom(address _from,
                          address _to,
                          uint256 _value)
                          public
                          returns (bool success)
    {
        uint256 allowance = allowed[_from][msg.sender];

        require(balances[_from] >= _value &&
                allowance       >= _value,
                "Insufficient allowed funds for transfer source.");

        balances[_from] -= _value;
        balances[_to  ] += _value;

        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }

        emit Transfer(_from, _to, _value);

        return true;
    }

    // -------------------------------------------------------------------------
    // Return the current balance (in tokens) of a specified address
    // -------------------------------------------------------------------------
    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return balances[_owner];
    }

    // -------------------------------------------------------------------------
    // Set
    // -------------------------------------------------------------------------
    function approve(address _spender,
                     uint256 _value)
                     public
                     returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // -------------------------------------------------------------------------
    // Return the remaining number of approved tokens
    // that can be transfered from one address to another specified address
    // -------------------------------------------------------------------------
    function allowance(address _owner,
                       address _spender)
                       public view
                       returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    // -------------------------------------------------------------------------
    // Return the total number of tokens in circulation
    // -------------------------------------------------------------------------
    function totalSupply() public view returns (uint256 totSupp)
    {
        return totalSupply;
    }
}
