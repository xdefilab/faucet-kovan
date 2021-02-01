pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Faucet {

    mapping(address => uint256) public withdrawAuth;
    uint256 public period = 8400;

    IERC20[] public tokens;
    mapping(address => uint256) public tokensInfo;

    address public core;


    constructor() public{
        core = msg.sender;
    }

    function withdraw() public {
        uint256 start = withdrawAuth[msg.sender];
        require((start == 0) || (start > 0 && (start + period) < block.number), "Please wait");
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 per = tokensInfo[address(tokens[i])];
            if (per > 0) {
                if (tokens[i].balanceOf(address(this)) > per) {
                    address _address = address(tokens[i]);
                    emit Withdraw(msg.sender, _address, tokensInfo[address(tokens[i])]);
                    tokens[i].transfer(msg.sender, per);
                }
            }

        }
        withdrawAuth[msg.sender] = block.number;
    }

    function setPer(address _token, uint256 _per) public onlyCore {
        require(tokensInfo[_token] != 0, "Not exist");
        tokensInfo[_token] = _per;
    }

    function addToken(IERC20 _token, uint256 _per) public onlyCore {
        require(tokensInfo[address(_token)] == 0, "The token has exist");
        require(_per > 0, "per > 0");
        uint256 index = tokens.length++;
        tokens[index] = _token;
        tokensInfo[address(_token)] = _per;
    }

    function setPeriod(uint256 _period) public onlyCore {
        emit SetPeriod(_period);
        period = _period;
    }

    function removeToken(IERC20 _token) public onlyCore {
        IERC20[] memory _tokens = tokens;
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (address(_tokens[i]) == address(_token)) {
                tokens[i] = tokens[_tokens.length - 1];
                delete tokens[_tokens.length - 1];
                delete tokensInfo[address(_token)];
                uint256 balance = _token.balanceOf(address(this));
                if (balance > 0) {
                    _token.transfer(core, _token.balanceOf(address(this)));
                }
                emit RemoveToken(address(_token));
                break;
            }
        }
    }

    function tokensLength() public view returns (uint256){
        return tokens.length;
    }

    modifier onlyCore() {
        require(msg.sender == core, "Not Authorized, Only Core");
        _;
    }

    event AddToken(address _token, uint256 _per);

    event SetPer(address _token, uint256 _per);

    event Withdraw(address withdrawer, address token, uint256 amount);

    event RemoveToken(address _token);

    event SetPeriod(uint256 _period);
}
