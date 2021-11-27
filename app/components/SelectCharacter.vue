<template>
    <div class="select-character-container">
        <h2>Mint your Warrior. The fate of Hydaelyn is in your hands!</h2>
        <div class="character-grid" v-if="warriors && warriors.length > 0">
            <div class="character-item" v-for="(warrior, index) in warriors">
                <div class="name-container">
                    <p>{{ warrior.name }}</p>
                </div>
                <img :src="warrior.imageURI" :alt="warrior.name" />
                <button
                    type="button"
                    class="character-mint-button"
                    @click="mintCharacterNFTAction(index)"
                >{{ `Mint ${warrior.name}` }}</button>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { ethers } from 'ethers'
import { CONTRACT_ADDRESS, transformWarriorData } from '~/utils/constants'
import Game from '~/utils/Game.json'

interface componentData {
    warriors: any
    contract: ethers.Contract | null
}

export default Vue.extend({
    name: 'SelectCharacter',
    props: {
        selectCharacter: {
            type: Function,
            required: true,
        },
    },
    data(): componentData {
        return {
            warriors: null,
            contract: null
        }
    },
    methods: {
        async characterMintHandler(sender: any, tokenId: any) {
            if (!this.contract) return
            const warrior = await this.contract.checkIfUserHasNFT()
            this.selectCharacter(transformWarriorData(warrior))
            alert(`Your NFT is all done -- see it here: https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/${tokenId.toNumber()}`)
        },
        async mintCharacterNFTAction(index: number) {
            try {
                if (!this.contract) return
                const txn = await this.contract.mintCharacterNFT(index)
                await txn.wait()
            } catch (err) {
                console.warn('Error minting warrior:', err)
            }
        },
        async configureContract() {
            const provider = new ethers.providers.Web3Provider(window.ethereum)
            const wallet = provider.getSigner()
            const contract = new ethers.Contract(CONTRACT_ADDRESS, Game.abi, wallet)
            return contract
        },
        async getWarriors() {
            try {
                if (!this.contract) return
                const txn = await this.contract.getAllDefaultCharacters()

                this.warriors = txn.map((data: any) => transformWarriorData(data))
                console.log(this.warriors)
            } catch (err) {
                console.error('Something went wrong:', err)
            }
        }
    },
    beforeDestroy() {
        if (this.contract) {
            this.contract.off('CharacterNFTMinted', this.characterMintHandler)
        }
    },
    mounted() {
        this.configureContract().then((contract: ethers.Contract) => {
            console.log(contract)
            if (!contract) return
            this.contract = contract
            this.contract.on('CharacterNFTMinted', this.characterMintHandler)
            this.getWarriors()
        })
    }
})
</script>

<style>
.select-character-container {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    color: white;
}

.select-character-container .character-grid {
    width: 100%;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
    grid-template-rows: repeat(auto-fit, minmax(300px, 1fr));
    grid-row-gap: 15px;
}

.character-grid .character-item {
    display: flex;
    flex-direction: column;
    position: relative;
    justify-self: center;
    align-self: center;
}

.character-item img {
    height: 300px;
    width: 350px;
    border-radius: 10px;
    object-fit: cover;
}

.character-item .name-container {
    position: absolute;
    background-color: #838383;
    border-radius: 5px;
    margin: 10px;
}

.character-item .name-container p {
    margin: 0;
    padding: 5px 10px 5px 10px;
    font-weight: bold;
}

.character-item .character-mint-button {
    position: absolute;
    bottom: 0;
    width: 100%;
    height: 40px;
    border-bottom-left-radius: 10px;
    border-bottom-right-radius: 10px;
    border: none;
    cursor: pointer;
    background-color: rgb(32, 129, 226);
    color: white;
    font-weight: bold;
    font-size: 16px;
}
</style>