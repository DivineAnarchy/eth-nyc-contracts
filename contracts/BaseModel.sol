//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract BaseModel is Ownable, ERC721Enumerable {
    uint256 public constant MAX_SUPPLY = 50;
    string public baseUri;

    constructor(string memory uri) ERC721("BaseModel", "BSM") {
        baseUri = uri;
    }

    function airdrop(address wallet, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Airdrop will surpass the max supply");

		for(uint256 i; i < amount; i++) {
            _safeMint(wallet, totalSupply());
		}
    }

	function _baseURI() internal view virtual override returns (string memory) {
		return baseUri;
	}

	function setBaseUri(string memory uri) external onlyOwner {
		baseUri = uri;
	}
}
