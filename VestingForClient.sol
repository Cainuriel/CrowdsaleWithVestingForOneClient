//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Crowdsale.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// TopStars Token: 0x0ecfd374b72462e9674d9904b620b53d44825709 mainnet

interface TokenInterface {

    function decimals() external view  returns(uint8);
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    
}


contract VestingForClient is Crowdsale, Ownable {
    
  uint256 public reservedTops;
  bool public startReclaim;
  uint256 public vestingTime = 7802829;  // 90 days and seven hours
  uint256 public initialDate;
  uint256 public VestingOne;
  uint256 public VestingTwo;
  uint256 public VestingThree;
  uint256 public VestingFour;
  uint256  public investment; 
  address public client; 
  mapping(address => uint256) public paidOut; // in BNBs
  mapping(address => uint256) public isclaimed;
  
  uint256 private amount;
  uint256 private amountTokens;
    
  TokenInterface TokenContract; 
  
    /**
   * Event for token purchase logging
   * @param amount total sale balance
   * @param date collection date
   */
  event WithdrawBNB(
    uint256 amount,
    uint256 date
  );
  
      /**
   * Event for token purchase logging
   * @param amount total sale balance
   * @param date collection date
   */
  event WithdrawTops(
    uint256 amount,
    uint256 date
  );

  constructor  (uint256 _rate, 
    ERC20 _token,
    address _addressToken
  ) Crowdsale(_rate,  payable(msg.sender), _token)   {
                    

        TokenContract = TokenInterface(_addressToken);    
        //console.log("Desplegado contrato de venta de los tokens del contrato: ", _token);      
  }

  function withDrawTops() public  onlyOwner() 
  {
      uint256 balance = TokenContract.balanceOf(address(this));
      require(TokenContract.transfer(owner(), balance));
      emit WithdrawTops(balance, block.timestamp);
  }
    
  function tokenBalance() public view returns (uint256)  
  {
      return TokenContract.balanceOf(address(this));
  }
  
  function setRate(uint256 _newrate) public onlyOwner() 
  {
      
      rate = _newrate;
  }

    function setClient(address _client, uint256 _amount) public onlyOwner
  { 
    require(!startReclaim, "La reclamacion de Tops es habilitada");
    client = _client;
    investment = _amount;
    paidOut[_client] = _amount;
    reservedTops = paidOut[_client] * rate;
    isclaimed[_client] = 4; 
  }
  
  function activateClaim() public onlyOwner() 
  {
        startReclaim = !startReclaim;
        initialDate = block.timestamp;
        VestingOne = initialDate;
        VestingTwo = initialDate + vestingTime;
        VestingThree = initialDate + (vestingTime * 2);
        VestingFour = initialDate + (vestingTime * 3);
        
        
  }
  
  // Tops balance reserved by the user
  function getReservedTops() public view returns (uint256)
  {
      uint256 query = paidOut[msg.sender];
      return _getTokenAmount(query);
  }
  
  function getBalanceTops() public view returns (uint256)
  {
      return TokenContract.balanceOf(msg.sender);
  }
  
    function TimeVesting() internal view returns (uint256)
    {
        
        if(block.timestamp >= VestingFour) {
            return  VestingFour;
        } else if(block.timestamp >= VestingThree) { 
            return  VestingThree;
        } else if(block.timestamp >= VestingTwo) {
            return  VestingTwo;
        } else if(block.timestamp >= VestingOne) {
            return  VestingOne;
        }
        
        return 0;
        
    }
  
    function vestingControlTokens(uint256 _vestingTime) internal returns (uint256)
    {

        // Reparto proporcional por vesting
        if(_vestingTime == VestingOne) {
            if(isclaimed[msg.sender] == 4) {
             amount = (paidOut[msg.sender] * 25) / (10**2);
           amountTokens = _getTokenAmount(amount);
           paidOut[msg.sender] = paidOut[msg.sender] - amount;
           isclaimed[msg.sender] = isclaimed[msg.sender] - 1;
           return amountTokens; } else {
                revert("Ya ha reclamado su Vesting. Espere al siguiente");
           }
        }
        
         if(_vestingTime == VestingTwo) {
            if(isclaimed[msg.sender] == 3) {
            amount = (paidOut[msg.sender] * 33) / (10**2);
           amountTokens = _getTokenAmount(amount);
           paidOut[msg.sender] = paidOut[msg.sender] - amount;
           isclaimed[msg.sender] = isclaimed[msg.sender] - 1;
           return amountTokens;
            } else if(isclaimed[msg.sender] == 4){
            amount = (paidOut[msg.sender] * 50) / (10**2);
           amountTokens = _getTokenAmount(amount);
           paidOut[msg.sender] = paidOut[msg.sender] - amount;
           isclaimed[msg.sender] = isclaimed[msg.sender] - 1;
           return amountTokens;
            }  else {
                revert("Ya ha reclamado su Vesting. Espere al siguiente");
          }
        }
        
        if(_vestingTime == VestingThree) {
            if(isclaimed[msg.sender] == 2) {
            amount = (paidOut[msg.sender] * 50) / (10**2);
           amountTokens = _getTokenAmount(amount);
           paidOut[msg.sender] = paidOut[msg.sender] - amount;
           isclaimed[msg.sender] = isclaimed[msg.sender] - 1;
           return amountTokens;
            } else if(isclaimed[msg.sender] == 3) {
            amount = (paidOut[msg.sender] * 33) / (10**2);
           amountTokens = _getTokenAmount(amount);
           paidOut[msg.sender] = paidOut[msg.sender] - amount;
           isclaimed[msg.sender] = isclaimed[msg.sender] - 1;
           return amountTokens;
            } else if(isclaimed[msg.sender] == 4){
            amount = (paidOut[msg.sender] * 75) / (10**2);
           amountTokens = _getTokenAmount(amount);
           paidOut[msg.sender] = paidOut[msg.sender] - amount;
           isclaimed[msg.sender] = isclaimed[msg.sender] - 1;
           return amountTokens;
            }  else {
                revert("Ya ha reclamado su Vesting. Espere al siguiente");
          }
        }
        
        if(_vestingTime == VestingFour) {
          if(isclaimed[msg.sender] != 0) {
          amount = paidOut[msg.sender];
          amountTokens = _getTokenAmount(amount); 
          paidOut[msg.sender] = paidOut[msg.sender] - amount;
          isclaimed[msg.sender] = 0;
          return amountTokens; }
        } else {
                revert("Ya ha reclamado todos sus tokens");
          }
        return 0;
  }
  
  function vestingPeriod() public view returns(uint256)  
  { return TimeVesting();
  }

  function claimToken() public 
  { require(client == msg.sender, "Esta cuenta no tiene permitida la reclamacion");
    require(startReclaim, "La reclamacion no es habilitada todavia");
    require(isclaimed[msg.sender] != 0 , "Usted no tiene nada reservado o ya ha reclamado todos sus tokens");

    uint256 vesting = TimeVesting();
    
    if (vesting == 0) {
        
        revert("El vesting no esta abierto. Compruebe el tiempo");
    }
    
    uint256 tokens = vestingControlTokens(vesting);

    _processPurchase(msg.sender, tokens);
    
    reservedTops = reservedTops - tokens;

  }

    receive ()  external payable 
  {
    revert();
  }

}
