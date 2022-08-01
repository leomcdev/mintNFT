// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import to shorten the code
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
// needed to validate
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract mintContract is ERC721, Ownable {
    
    uint256 public mintPrice = 0.08 ether; 
    uint256 public totalSupply = 100;   
    uint256 public maxSupply;
    bool public isMintEnabled; // false as default
    mapping (address => uint256) public mintedWallets;
    mapping (uint256 => string) private _tokenURIs;
    
    //added
    uint256 public nftCounter; 


    // runs first
    constructor() payable ERC721('CHR-Test', 'SymbolName') { 
        nftCounter = 0;
    }

    // set only owner to modifier
    // if this function is called, mint is enabled
    function toggleIsMintEnabled() external onlyOwner { 
        isMintEnabled = !isMintEnabled;
    }

    // only owner can change maxsupply 
    function sexMaxSupply(uint256 maxSupply_) external onlyOwner{
        maxSupply = maxSupply_;
    }

    // each wallet can only mint one NFT
    function mint(string memory _tokenURI) external payable {
        require(isMintEnabled, 'Minting not enabled');
        require(mintedWallets[msg.sender] < 1, 'Exceeds max per wallet');
        require(msg.value == mintPrice, 'Incorrect value');
        require(maxSupply > totalSupply, 'Mint sold out');

        //track the amount of minted NFTs
        mintedWallets[msg.sender]++;
        totalSupply++;
        uint256 tokenId = totalSupply;
        
        nftCounter++;
        _setTokenURI(tokenId, _tokenURI);

        // import from erc721, mint and make sure the right buyer gets it
        _safeMint(msg.sender, tokenId);
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal virtual {
    require(
        _exists(_tokenId),
        "ERC721Metadata: URI set of nonexistent token"
    );  // Checks if the tokenId exists
    _tokenURIs[_tokenId] = _tokenURI;
}

function tokenURI(uint256 _tokenId) public view virtual override returns(string memory) {
    require(
        _exists(_tokenId),
        "ERC721Metadata: URI set of nonexistent token"
    );
    return _tokenURIs[_tokenId];
}
