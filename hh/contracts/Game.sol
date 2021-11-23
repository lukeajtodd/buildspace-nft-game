// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./libs/Base64.sol";

contract Game is ERC721 {
  struct Attributes {
    uint256 characterIndex;
    string name;
    string imageURI;
    uint256 health;
    uint256 maxHealth;
    uint256 attack;
  }

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  Attributes[] private defaultCharacters;

  mapping(uint256 => Attributes) public nftHolderAttributes;

  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint256[] memory characterHealth,
    uint256[] memory characterAttack
  ) ERC721("Warriors", "WOL") {
    for (uint256 i = 0; i < characterNames.length; i++) {
      defaultCharacters.push(
        Attributes(
          i,
          characterNames[i],
          characterImageURIs[i],
          characterHealth[i],
          characterHealth[i],
          characterAttack[i]
        )
      );

      Attributes memory character = defaultCharacters[i];
      console.log(
        "Created character: %s with health: %s",
        character.name,
        character.health
      );
    }

    _tokenIds.increment();
  }

  function mintCharacterNFT(uint256 _characterIndex) external {
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = Attributes(
      _characterIndex,
      defaultCharacters[_characterIndex].name,
      defaultCharacters[_characterIndex].imageURI,
      defaultCharacters[_characterIndex].health,
      defaultCharacters[_characterIndex].maxHealth,
      defaultCharacters[_characterIndex].attack
    );

    console.log(
      "Minted NFT with tokenID: %s and characterIndex: %s",
      newItemId,
      _characterIndex
    );

    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
  {
    Attributes memory character = nftHolderAttributes[_tokenId];

    string memory health = Strings.toString(character.health);
    string memory maxHealth = Strings.toString(character.maxHealth);
    string memory attack = Strings.toString(character.attack);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            character.name,
            " -- NFT #: ",
            Strings.toString(_tokenId),
            '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
            character.imageURI,
            '", "attributes": [ { "trait_type": "Health Points", "value": ',
            health,
            ', "max_value":',
            maxHealth,
            '}, { "trait_type": "Attack Damage", "value": ',
            attack,
            "} ]}"
          )
        )
      )
    );

    string memory output = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
  }
}
