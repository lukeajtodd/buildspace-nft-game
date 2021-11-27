<template>
  <div class="App">
    <div class="container">
      <div class="header-container">
        <p class="header gradient-text">⚔️ Metaverse Slayer ⚔️</p>
        <p class="sub-text">Team up to protect the Metaverse!</p>
        <div class="connect-wallet-container">
          <img
            src="https://64.media.tumblr.com/tumblr_mbia5vdmRd1r1mkubo1_500.gifv"
            alt="Monty Python Gif"
          />
        </div>
        <template v-if="!currentAccount">
          <NotConnected :connectWallet="connectWallet" />
        </template>
        <template v-else-if="currentAccount && !selectedCharacter">
          <SelectCharacter :selectCharacter="selectCharacter" />
        </template>
        <template v-else>
          <Arena :selectedCharacter="selectedCharacter"/>
        </template>
      </div>
      <div class="footer-container">
        <a
          class="footer-text"
          :href="twitterLink"
          target="_blank"
          rel="noreferrer"
        >{{ `built with @${twitterHandle}` }}</a>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { ethers } from 'ethers'
import Game from '~/utils/Game.json'
import { CONTRACT_ADDRESS, transformWarriorData } from '~/utils/constants'

import NotConnected from '~/components/NotConnected.vue'
import SelectCharacter from '~/components/SelectCharacter.vue'
import Arena from '~/components/Arena.vue'

const TWITTER_HANDLE = '_buildspace';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;

interface BaseComponentData {
  connectedContract: ethers.Contract | null
  currentAccount: string | null
  selectedCharacter: any
  twitterHandle: string
  twitterLink: string
}

export default Vue.extend({
  data(): BaseComponentData {
    return {
      connectedContract: null,
      currentAccount: null,
      selectedCharacter: null,
      twitterLink: TWITTER_LINK,
      twitterHandle: TWITTER_HANDLE,
    };
  },
  components: {
    notConnected: NotConnected,
    selectCharacter: SelectCharacter,
    arean: Arena
  },
  watch: {
    currentAccount(v) {
      if (v) {
        this.checkIfUserHasWarrior()
      }
    }
  },
  methods: {
    selectCharacter() { },
    async checkIfWalletConnected() {
      // @ts-ignore
      const { ethereum } = window

      if (!ethereum) {
        console.log('Make sure you have Metamask!')
        return
      }

      const accounts = await ethereum.request({ method: 'eth_accounts' })

      if (accounts.length !== 0) {
        const account = accounts[0]
        console.log('Found an authorised account: ', account)
        this.currentAccount = account
      } else {
        console.log('No accounts found')
      }
    },
    async checkIfUserHasWarrior() {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const contract = new ethers.Contract(CONTRACT_ADDRESS, Game.abi, signer)

      const txn = await contract.checkIfUserHasNFT()
      if (txn.name) {
        this.selectedCharacter = transformWarriorData(txn)
      } else {
        console.log('No warrior NFT found')
      }

    },
    async verifyRinkebyNetwork() {
      // @ts-ignore
      const { ethereum } = window

      if (!ethereum) {
        console.log('Make sure you have Metamask!')
        return
      }

      const network = await ethereum.request({ method: 'eth_chainId' })

      if (network !== '0x4') {
        console.log('Make sure you are on the Rinkeby network!')
        return
      }
    },
    async connectWallet() {
      await this.verifyRinkebyNetwork()
      try {
        // @ts-ignore
        const { ethereum } = window;

        if (!ethereum) {
          alert("Get MetaMask!");
          return;
        }

        /*
        * Fancy method to request access to account.
        */
        const accounts = await ethereum.request({ method: "eth_requestAccounts" });

        /*
        * Boom! This should print out public address once we authorize Metamask.
        */
        console.log("Connected", accounts[0]);
        this.currentAccount = accounts[0];
      } catch (error) {
        console.log(error)
      }
    },
    configureConnectedContract(): any {
      // @ts-ignore
      const { ethereum } = window
      const contractAddress: string = CONTRACT_ADDRESS

      if (!ethereum) {
        console.log("Ethereum object doesn't exist!")
        return false
      }

      if (this.connectedContract) {
        return this.connectedContract
      } else {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();

        this.connectedContract = new ethers.Contract(contractAddress, Game.abi, signer)
        // if (this.connectedContract) {
        //   this.connectedContract.on("NewNFTMinted", (from, tokenId) => {
        //     console.log(from, tokenId.toNumber())
        //     alert(`Hey there! We've minted your NFT. It may be blank right now. It can take a max of 10 min to show up on OpenSea. Here's the link: <https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/${tokenId.toNumber()}>`)
        //   })
        // }
      }
    }
  },
  mounted() {
    this.checkIfWalletConnected()
    this.checkIfUserHasWarrior()
  },
})
</script>
