//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Polly is Ownable, ERC1155 {
	using Strings for uint256;

    uint public constant FIREPOLLY   = 0;
    uint public constant WATERPOLLY  = 1;
    uint public constant HALO        = 2;
    uint public constant HORNS       = 3;
    uint public constant MASK        = 4;
    uint public constant SKATEBOARD  = 5;
    uint public constant SURFBOARD   = 6;
    uint public constant BUSTERSWORD = 7;
    uint public constant RPG         = 8;
	string public baseUri;

	constructor(string memory _uri) ERC1155(_uri) {
		mintToken(msg.sender, FIREPOLLY, 1);
		mintToken(msg.sender, WATERPOLLY, 1);
		mintToken(msg.sender, HALO, 1);
		mintToken(msg.sender, SKATEBOARD, 1);
		mintToken(msg.sender, RPG, 1);

		baseUri = _uri;
	}

	function mintToken(address to, uint256 tokenType, uint256 quantity) public {
		require(exists(tokenType), "Nonexstent token");
		_mint(to, tokenType, quantity, "");
	}

	function uri(uint256 tokenId) public view override returns (string memory) {
		require(exists(tokenId), "Nonexistent token");
		return bytes(baseUri).length != 0 ? string(abi.encodePacked(baseUri, tokenId.toString())) : '';
	}

	function exists(uint256 _id) public pure returns (bool) {
		return _id >= 0 && _id <= 8;
	}

	function setUri(string memory _uri) external onlyOwner {
		baseUri = _uri;
	}
}
