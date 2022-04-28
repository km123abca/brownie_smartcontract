//pragma solidity ^0.6.0;
//SPDX-License_Identifier: MIT
// pragma solidity >=0.6.6 <0.9.0;
pragma solidity ^0.6.0;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
//THis is the npm location of the aggregatorv3interface interface
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
contract FundMe{
    using SafeMathChainlink for uint256;
    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;
    constructor(address _priceFeed) public{
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }
    function fund() public payable{
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value)>= minimumUSD,"More Eth Required");
        addressToAmountFunded[msg.sender]+= msg.value;
        funders.push(msg.sender);
    }    
    function getVersion() public view returns (uint256){
    //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);//the contract adddress that we want to interact with
    return priceFeed.version();
    }

    function getPrice() public view returns(uint256){
       // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (uint80 roundId,int256 answer,uint256 startedAt,uint256 updatedAt,uint80 answeredInRound)=priceFeed.latestRoundData();
        // return uint256(answer * 10000000000);//answer will have 8 decimal places ,its already divided by 1e8 we add 10 so that it becomes wei fig
        return uint256(answer*10000000000);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1000000000000000000;
        return ethAmountInUsd;
    }
    function withdraw() payable onlyOwner public{
        // require(msg.sender == owner); //This is no more necessary since a common modifier has been included
        msg.sender.transfer(address(this).balance);
        for(uint i =0;i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder]=0;
        }
        funders = new address[](0);
    }
    function getEntranceFee() public view returns (uint256){
        uint256 minimumUSD = 50* 10 **18;
        uint256 price = getPrice();
        uint256 precision = 1* 10**18;
        return (minimumUSD * precision)/price;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
}
