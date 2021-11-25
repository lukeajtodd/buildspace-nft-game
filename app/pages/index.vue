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
      </div>
      <div class="footer-container">
        <a
          class="footer-text"
          :href="twitterLink"
          target="_blank"
          rel="noreferrer"
        >
          {{`built with @${twitterHandle}`}}
        </a>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { ethers } from 'ethers'

const TWITTER_HANDLE = '_buildspace';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;

export default Vue.extend({
  data() {
    return {
      twitterLogo: `https://${TWITTER_HANDLE}.com/favicon.ico`,
      twitterLink: TWITTER_LINK,
      twitterHandle: TWITTER_HANDLE,
    };
  }
})
</script>
