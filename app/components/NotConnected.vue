<template>
    <button @click="connectWallet" class="cta-button connect-wallet-button">Connect to Wallet</button>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
    name: 'NotConnected',
    props: {
        connectWallet: {
            type: Function,
            required: true,
        },
    }
})
</script>