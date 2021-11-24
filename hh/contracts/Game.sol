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

  struct Boss {
    string name;
    string imageURI;
    uint256 health;
    uint256 maxHealth;
    uint256 attack;
  }

  Boss public bigBoss;

  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint256[] memory characterHealth,
    uint256[] memory characterAttack,
    string memory bossName,
    string memory bossImageURI,
    uint256 bossHealth,
    uint256 bossAttack
  ) ERC721("Warriors", "WOL") {

    bigBoss = Boss(
      bossName,
      bossImageURI,
      bossHealth,
      bossHealth,
      bossAttack
    );

    console.log("Initialised boss %s with %d health and %d attack", bigBoss.name, bigBoss.health, bigBoss.attack);

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

    nftHolders[msg.sender] = newItemId;

    _tokenIds.increment();
  }

  function attackBoss() public {
    // Get the state of the player's NFT
    uint256 tokenId = nftHolders[msg.sender];
    console.log(msg.sender);
    Attributes storage player = nftHolderAttributes[tokenId];
    console.log("Player with character %s is about to attack. They have %d health and %d AD", player.name, player.health, player.attack);
    console.log("The boss %s has %d health and %d AD", bigBoss.name, bigBoss.health, bigBoss.attack);

    require(player.health > 0, "You cannot attack if you're dead!");
    require(bigBoss.health > 0, "The boss is already dead!");

    if (bigBoss.health < player.attack) {
      bigBoss.health = 0;
    } else {
      bigBoss.health -= player.attack;
    }

    if (player.health < bigBoss.attack) {
      player.health = 0;
    } else {
      player.health -= bigBoss.attack;
    }

    console.log("Player attacked. The boss health is now %d", bigBoss.health);
    console.log("Boss attacked. The player health is now %d\n", player.health);
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
