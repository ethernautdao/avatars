//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Ethernauts is ERC721Enumerable, Ownable {
    using Address for address payable;

    // Can be set once on deploy
    uint public immutable maxTokens;
    uint public immutable maxGiftable;

    // Can be changed by owner
    string public baseTokenURI;
    uint public mintPrice;

    // Internal
    uint private _tokensGifted;

    constructor(
        uint maxGiftable_,
        uint maxTokens_,
        uint mintPrice_
    ) ERC721("Ethernauts", "ETHNTS") {
        require(maxGiftable_ <= 100, "Max giftable supply too large");
        require(maxTokens_ <= 10000, "Max token supply too large");

        maxGiftable = maxGiftable_;
        maxTokens = maxTokens_;
        mintPrice = mintPrice_;
    }

    // --------------------
    // Public external ABI
    // --------------------

    function mint() external payable {
        require(msg.value >= mintPrice, "bad msg.value");

        _mintNext(msg.sender);
    }

    function exists(uint tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokensGifted() public view returns (uint) {
        return _tokensGifted;
    }

    // -----------------------
    // Protected external ABI
    // -----------------------

    function gift(address to) external onlyOwner {
        require(_tokensGifted < maxGiftable, "No more Ethernauts can be gifted");

        _mintNext(to);

        _tokensGifted += 1;
    }

    function setMintPrice(uint newMintPrice) external onlyOwner {
        mintPrice = newMintPrice;
    }

    function setBaseURI(string memory baseTokenURI_) public onlyOwner {
        baseTokenURI = baseTokenURI_;
    }

    function withdraw(address payable beneficiary) external onlyOwner {
        beneficiary.sendValue(address(this).balance);
    }

    // -------------------
    // Internal functions
    // -------------------

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _mintNext(address to) internal {
        uint tokenId = totalSupply();

        _mint(to, tokenId);
    }

    function _mint(address to, uint tokenId) internal virtual override {
        require(totalSupply() < maxTokens, "No more Ethernauts can be minted");

        super._mint(to, tokenId);
    }
}
