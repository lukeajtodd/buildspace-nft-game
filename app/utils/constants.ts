const CONTRACT_ADDRESS = '0xf587c1F50beF9A743Fbc72EA40AEE50B933e84A7'

const transformCharacterData = (characterData: any) => {
    return {
      name: characterData.name,
      imageURI: characterData.imageURI,
      health: characterData.health,
      maxHealth: characterData.maxHealth,
      attack: characterData.attack,
    };
  }

export { CONTRACT_ADDRESS, transformCharacterData }