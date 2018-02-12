pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function add(uint256 x, uint256 y) pure internal returns (uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function sub(uint256 x, uint256 y) pure internal returns (uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function mul(uint256 x, uint256 y) pure internal returns (uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
/*
 * Haltable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.
 *
 *
 * Originally envisioned in FirstBlood ICO contract.
 */
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    require (!halted);
    _;
  }

  modifier onlyInEmergency {
    require (halted);
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}
/////////////////////////////////////////////////////////////////////////////////////////////
//
// Tokens for Test only should be removed. TODO
//
contract preDGZToken is StandardToken {
    using SafeMath for uint256;

    /*/ Public variables of the token /*/
    string public constant name = "Dogezer preDGZ Token";
    string public constant symbol = "preDGZ";
    uint8 public decimals = 8;
    uint256 public totalSupply = 200000000000000;

    /*/ Initializes contract with initial supply tokens to the creator of the contract /*/
    function preDGZToken() public
    {
        balances[msg.sender] = totalSupply;              // Give the creator all initial tokens
    }
}

contract DGZToken is StandardToken {
    using SafeMath for uint256;

    /*/ Public variables of the token /*/
    string public constant name = "Dogezer DGZ Token";
    string public constant symbol = "DGZ";
    uint8 public decimals = 8;
    uint256 public totalSupply = 10000000000000000;

    /*/ Initializes contract with initial supply tokens to the creator of the contract /*/
    function DGZToken() public
    {
        balances[msg.sender] = totalSupply;              // Give the creator all initial tokens
    }
}


/////////////////////////////////////////////////////////////////////////////////////////////
contract DogezerICOPublicCrowdSale is Haltable{
    using SafeMath for uint;

    string public name = "Dogezer Public Sale ITO";

    address public beneficiary;

    uint public startTime = 1518699600;
    uint public stopTime = 1520514000;

    uint public totalTokensAvailableForSale = 9800000000000000;
    uint public preDGZTokensSold = 20699056632305;
    uint public privateSalesTokensSold = 92644444444444;
    uint public tokensAvailableForSale = 0;
    uint public tokensSoldOnPublicRound = 0;

    StandardToken public tokenReward;
    StandardToken public tokenRewardPreDGZ;
        

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public nonWLBalanceOf;
    mapping(address => uint256) public preBalanceOf;
    mapping(address => bool) public whiteList;

    event DGZTokensWithdraw(address where, uint amount);
    event DGZTokensSold(address where, uint amount);
    event TokensWithdraw(address where, address token, uint amount);
    event FundsWithdrawal(address where, uint amount);

    bool[] public yearlyTeamTokensPaid = [false, false, false];
    uint public yearlyTeamAmount= 0;
    bool public bountyPaid = false;
    uint public bountyAmount = 0;

    bool public crowdsaleClosed = false;
    uint public constant maxPurchaseNonWhiteListed = 10 * 1 ether;
    uint public preDGZtoDGZExchangeRate = 914285714;

    uint public discountValue5 = 50.0 * 1 ether;
    uint public discountValue10 = 100.0 * 1 ether;

    uint[] public price1stWeek = [ 5625000, 5343750, 5062500];
    uint[] public price2ndWeek = [ 5940000, 5643000, 5346000];
    uint[] public price3rdWeek = [ 6250000, 5937500, 5625000];

    /*  at initialization, setup the owner */
    function DogezerICOPublicCrowdSale(
        address addressOfPreDGZToken,
        address addressOfDGZToken,
        address addressOfBeneficiary
    ) public
    {
        beneficiary = addressOfBeneficiary;
        tokenRewardPreDGZ = StandardToken(addressOfPreDGZToken);
        tokenReward = StandardToken(addressOfDGZToken);
        tokensAvailableForSale = totalTokensAvailableForSale - preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 - privateSalesTokensSold;
        tokensSoldOnPublicRound = 0;
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Modifiers
    //
    modifier onlyAfterStart() {
        require (now >= startTime);
        _;
    }

    modifier onlyBeforeEnd() {
        require (now < stopTime);
        _;
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Payable function
    //
    /* The function without name is the default function that is called whenever anyone sends funds to a contract */
    function () payable stopInEmergency onlyAfterStart onlyBeforeEnd public
    {
        require (crowdsaleClosed == false);
        require (tokensAvailableForSale > tokensSoldOnPublicRound);
        require (msg.value > 500000000000000);

        if ((balanceOf[msg.sender] + msg.value) > maxPurchaseNonWhiteListed && whiteList[msg.sender] == false) 
	{
            //Tokens are not being reserved for the purchasers who are not in a whitelist yet
            nonWLBalanceOf[msg.sender] += msg.value;
        } 
	else 
	{
            sendTokens(msg.sender, msg.value); 
	}
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Add multiple addresses to white list to allow purchase for more than 10 ETH
    // Pass parameters as ["0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c"]
    //
    function addListToWhiteList (address[] _addresses) public onlyOwner
    {
        for (uint i = 0; i < _addresses.length; i++)
        {
	    if (nonWLBalanceOf[_addresses[i]] > 0)
	    {
		sendTokens(_addresses[i], nonWLBalanceOf[_addresses[i]]);
		nonWLBalanceOf[_addresses[i]] = 0;
	    }
	    whiteList[_addresses[i]] = true;
        }
    }
	
	
    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Add single address to white list to allow purchase for more than 10 ETH
    // 
    //	
    function addToWhiteList (address _address) public onlyOwner
    {
	if (nonWLBalanceOf[_address] > 0)
	{
	    sendTokens(_address, nonWLBalanceOf[_address]);
	    nonWLBalanceOf[_address] = 0;
	}
	whiteList[_address] = true;
    }	
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Finalize sales and set bounty & yearly paid value
    //
    function finalizeSale () public onlyOwner
    {
        require (crowdsaleClosed == false);
        crowdsaleClosed = true;
	uint totalSold = tokensSoldOnPublicRound + preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 + privateSalesTokensSold;
        bountyAmount = totalSold / 980 * 15;
        yearlyTeamAmount= totalSold / 980 * 5 / 3;
    }
    

    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Burn tokens after sales close
    //
    function tokenBurn (uint _amount) public onlyOwner
    {
        require (crowdsaleClosed == true);
        tokenReward.transfer(address(0), _amount);
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Withdraw bounty tokens after sales close
    //
    function bountyTokenWithdrawal () public onlyOwner
    {
        require (crowdsaleClosed == true);
        require (bountyPaid == false);

        tokenReward.transfer(beneficiary, bountyAmount);
        bountyPaid = true;
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Withdraw yearly tokens after sales close
    //
    function yearlyOwnerTokenWithdrawal () public onlyOwner 
    {
        require (crowdsaleClosed == true);
        require (
            ((now > stopTime + 1 years) && (yearlyTeamTokensPaid[0] == false))
            || ((now > stopTime + 2 years) && (yearlyTeamTokensPaid[1] == false))
            || ((now > stopTime + 3 years) && (yearlyTeamTokensPaid[2] == false))
        );

        tokenReward.transfer(beneficiary, yearlyTeamAmount);

        if (yearlyTeamTokensPaid[0] == false)
            yearlyTeamTokensPaid[0] = true;
        else if (yearlyTeamTokensPaid[1] == false)
            yearlyTeamTokensPaid[1] = true;
        else if (yearlyTeamTokensPaid[2] == false)
            yearlyTeamTokensPaid[2] = true;
    }

	
    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Exchange contract preDGZ->DGZ tokens
    //
    function exchangePreDGZTokens() stopInEmergency onlyAfterStart public
    {
        uint tokenAmount = tokenRewardPreDGZ.allowance(msg.sender, this);
        require(tokenAmount > 0);
        require(tokenRewardPreDGZ.transferFrom(msg.sender, address(0), tokenAmount));
        uint amountSendTokens = tokenAmount * preDGZtoDGZExchangeRate  / 100000000;
        preBalanceOf[msg.sender] += tokenAmount;
        tokenReward.transfer(msg.sender, amountSendTokens);
    }
	
    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Exchange contract preDGZ->DGZ tokens
    // TODO Alex comment
    //
    function manuallyExchangeContractPreDGZtoDGZ(address _address, uint preDGZAmount) public onlyOwner
    {
        require (_address != address(0));
        require (preDGZAmount > 0);

        uint amountSendTokens = preDGZAmount * preDGZtoDGZExchangeRate  / 100000000;
        preBalanceOf[_address] += preDGZAmount;
        tokenReward.transfer(_address, amountSendTokens);
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Set token price
    //
    function setTokenPrice (uint week, uint price, uint price5, uint price10) public onlyOwner
    {
        require (crowdsaleClosed == false);
        require (week >= 1 && week <= 3);
        if (week == 1)
            price1stWeek = [price, price5, price10];
        else if (week == 2)
            price2ndWeek = [price, price5, price10];
        else if (week == 3)
            price3rdWeek = [price, price5, price10];
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Set preDGZ to DGZ conversion rate
    //
    function setPreDGZtoDgzRate (uint rate) public onlyOwner
    {
        preDGZtoDGZExchangeRate = rate;
        tokensAvailableForSale = totalTokensAvailableForSale - preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 - privateSalesTokensSold;
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Set number of tokens sold on private sale
    //
    function setPrivateSaleTokensSold (uint tokens) public onlyOwner
    {
        privateSalesTokensSold = tokens;
        tokensAvailableForSale = totalTokensAvailableForSale - preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 - privateSalesTokensSold;
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Function which sends tokens
    //
    function sendTokens(address msg_sender, uint msg_value) internal
    {
        var prices = price1stWeek;

        if (now >= startTime + 2 weeks)
            prices = price3rdWeek;
        else if (now >= startTime + 1 weeks)
            prices = price2ndWeek;


        uint currentPrice = prices[0];

        if (balanceOf[msg_sender] + msg_value >= discountValue5)
        {
            currentPrice = prices[1];
            if (balanceOf[msg_sender] + msg_value >= discountValue10)
                currentPrice = prices[2];
        }

        uint amountSendTokens = msg_value / currentPrice;

        if (amountSendTokens > (tokensAvailableForSale - tokensSoldOnPublicRound))
        {
            uint tokensAvailable = tokensAvailableForSale - tokensSoldOnPublicRound;
            uint refund = msg_value - (tokensAvailable * currentPrice);
            amountSendTokens = tokensAvailable;
	    tokensSoldOnPublicRound += amountSendTokens;			
            msg_sender.transfer(refund);
            balanceOf[msg_sender] += (msg_value - refund);
        }
        else
        {
	    tokensSoldOnPublicRound += amountSendTokens;			
            balanceOf[msg_sender] += msg_value;
        }

        tokenReward.transfer(msg_sender, amountSendTokens);
        DGZTokensSold(msg_sender, amountSendTokens);
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Withdraw funds to beneficiary.
    //
    function fundWithdrawal (uint _amount) public onlyOwner
    {
        require (crowdsaleClosed == true);
        beneficiary.transfer(_amount);
        FundsWithdrawal(beneficiary, _amount);
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Refund funds.
    //
    function refundNonWhitelistedPerson (address _address) public onlyOwner
    {
	uint refundAmount = nonWLBalanceOf[_address];
	nonWLBalanceOf[_address] = 0;
        _address.transfer(refundAmount);
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Withdraw tokens to beneficiary. Would be used to process BTC payments.
    //
    function tokenWithdrawal (uint _amount) public onlyOwner
    {
        require (crowdsaleClosed == false);
        tokenReward.transfer(beneficiary, _amount);
        tokensSoldOnPublicRound += _amount;
        DGZTokensWithdraw(beneficiary, _amount);
    }


    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Withdraw tokens other than DGZ to beneficiary
    // Generally need this to handle case when user just send preDGZ to a contract and not calling
    // the right functions to do the conversion
    //
    function anyTokenWithdrawal (address _address, uint _amount) public onlyOwner
    {
        //This function is not to be used to withdraw DGZ tokens
        require(_address != address(tokenReward));

        StandardToken token = StandardToken(_address);
        token.transfer(beneficiary, _amount);
        TokensWithdraw(beneficiary, _address, _amount);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Change beneficiary address
    //
    function changeBeneficiary(address _newBeneficiary) public onlyOwner
    {
        if (_newBeneficiary != address(0)) {
            beneficiary = _newBeneficiary;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Repopen sales in emergency
    //
    function reopenSale () public onlyOwner
    {
        require (crowdsaleClosed == true);
        crowdsaleClosed = false;
    }
}
