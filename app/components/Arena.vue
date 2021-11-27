<template>
    <div class="arena-container">
        <div v-if="boss" class="boss-container">
            <div class="boss-content" v-bind:class="attackState">
                <h2>🔥 {{ boss.name }} 🔥</h2>
                <div class="image-content">
                    <img :src="boss.imageURI" :alt="`Boss ${boss.name}&#x60;`" />
                    <div class="health-bar">
                        <progress :value="boss.health" :max="boss.maxHealth" />
                        <p>{{ `${boss.health} / ${boss.maxHealth} HP` }}</p>
                    </div>
                </div>
            </div>
            <div class="attack-container">
                <button class="cta-button" @click="runAttackAction">{{ `💥 Attack ${boss.name}` }}</button>
            </div>
        </div>
        <div v-if="warriorNFT" class="players-container">
            <div class="player-container">
                <h2>Your Character</h2>
                <div class="player">
                    <div class="image-content">
                        <h2>{{ warriorNFT.name }}</h2>
                        <img
                            :src="warriorNFT.imageURI"
                            :alt="`Character ${warriorNFT.name}&#x60;`"
                        />
                        <div class="health-bar">
                            <progress :value="warriorNFT.health" :max="warriorNFT.maxHealth" />
                            <p>{{`${warriorNFT.health} / ${warriorNFT.maxHealth} HP`}}</p>
                        </div>
                    </div>
                    <div class="stats">
                        <h4>{{`⚔️ Attack Damage: ${warriorNFT.attack}`}}</h4>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { ethers } from 'ethers'
import { CONTRACT_ADDRESS, transformCharacterData } from '~/utils/constants'
import Game from '~/utils/Game.json'

interface componentData {
    attackState: string
    boss: any
    contract: ethers.Contract | null
}

export default Vue.extend({
    name: 'Arena',
    props: {
        setCharacter: {
            type: Function,
            required: true
        },
        warriorNFT: {
            type: Object,
            required: true
        }
    },
    data(): componentData {
        return {
            attackState: '',
            boss: null,
            contract: null
        }
    },
    methods: {
        attackHandler(newBossHealth: any, newPlayerHealth: any) {
            const bossHealth = newBossHealth.toNumber()
            const playerHealth = newPlayerHealth.toNumber()

            this.boss = {
                ...this.boss,
                health: bossHealth
            }

            this.setCharacter({
                ...this.warriorNFT,
                health: playerHealth
            })
        },
        async runAttackAction() {
            if (!this.contract) return

            try {
                this.attackState = 'attacking'
                const txn = await this.contract.attackBoss()
                await txn.wait()
                this.attackState = 'hit'
            } catch (err) {
                console.error(err)
                this.attackState = ''
            }
        },
        configureContact() {
            const provider = new ethers.providers.Web3Provider(window.ethereum)
            const signer = provider.getSigner()
            const contract = new ethers.Contract(CONTRACT_ADDRESS, Game.abi, signer)
            this.contract = contract
        },
        async fetchBoss() {
            if (!this.contract) return

            try {
                const txn = await this.contract.getBoss()
                console.log(txn)
                this.boss = transformCharacterData(txn)
            } catch (err) {
                console.error(err)
            }

        }
    },
    beforeDestroy() {
        if (!this.contract) return
        this.contract.off('AttackComplete', this.attackHandler)
    },
    mounted() {
        this.configureContact()
        this.fetchBoss().then(() => {
            if (!this.contract) return
            this.contract.on('AttackComplete', this.attackHandler)
        })
    }
})
</script>

<style>
.arena-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin: auto;
    color: white;
}

.arena-container .boss-container {
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    margin-bottom: 50px;
}

.boss-container .boss-content {
    display: flex;
    flex-direction: column;
    padding: 15px;
    border-radius: 10px;
    background-image: linear-gradient(
        to right,
        #ff8177 0%,
        #ff867a 0%,
        #ff8c7f 21%,
        #f99185 52%,
        #cf556c 78%,
        #b12a5b 100%
    );
    background-size: 600% 600%;
    animation: gradient-animation 8s ease infinite;
    margin-bottom: 25px;
}

.boss-content h2 {
    margin: 0;
    padding: 5px 0 10px 0;
}

.boss-content .image-content,
.player .image-content {
    position: relative;
}

.boss-content .image-content img {
    width: 350px;
    height: 300px;
    border-radius: 10px;
    object-fit: cover;
}

.image-content .health-bar {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 30px;
}

.health-bar progress[value] {
    -webkit-appearance: none;
    appearance: none;
    width: 100%;
    height: 100%;
}

.health-bar progress[value]::-webkit-progress-bar {
    background-color: #e5652e;
    border-bottom-left-radius: 15px;
    border-bottom-right-radius: 15px;
    overflow: hidden;
}

.health-bar progress[value]::-webkit-progress-value {
    background-color: #70cb1b;
}

.health-bar p {
    position: absolute;
    width: 100%;
    font-weight: bold;
    color: black;
    bottom: -10px;
}

.arena-container .players-container {
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: space-around;
}

.players-container .player {
    display: flex;
    flex-direction: column;
    max-height: 80%;
    padding: 10px;
    border-radius: 10px;
    background-color: gray;
}

.player .image-content img {
    width: 250px;
    height: 300px;
    border-radius: 10px;
    object-fit: cover;
}

.players-container .active-players {
    display: flex;
    flex-direction: column;
}

.active-players .players-list {
    display: flex;
    flex-direction: column;
    max-height: 400px;
    overflow: scroll;
}

.players-list .active-player-item {
    display: flex;
    align-items: center;
    background-color: #b12a5b;
    border-radius: 8px;
    margin: 5px;
    padding: 10px;
    font-size: 18px;
    font-weight: bold;
}

.active-player-item .player-image {
    width: 64px;
    height: 64px;
    background-color: gray;
    margin-right: 15px;
    border-radius: 8px;
}

.active-player-item .player-content {
    flex-direction: column;
    text-align: left;
}

.players-container .attack-container {
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.attack-container button {
    height: 60px;
    font-size: 18px;
    background-image: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    background-size: 200% 200%;
    animation: gradient-animation 4s ease infinite;
}

/* Effects */
.boss-container .attacking {
    animation: shake 1.2s cubic-bezier(0.36, 0.07, 0.19, 0.97) both infinite;
    transform: translate3d(0, 0, 0);
    backface-visibility: hidden;
    perspective: 1000px;
}

.boss-container .hit {
    animation: hit-bounce 1s ease;
}

@keyframes shake {
    10%,
    90% {
        transform: translate3d(-1px, 0, 0);
    }

    20%,
    80% {
        transform: translate3d(2px, 0, 0);
    }

    30%,
    50%,
    70% {
        transform: translate3d(-4px, 0, 0);
    }

    40%,
    60% {
        transform: translate3d(4px, 0, 0);
    }
}

@keyframes hit-bounce {
    0% {
        transform: scale(1) translateY(0);
    }
    10% {
        transform: scale(1.2, 0.6);
    }
    30% {
        transform: scale(0.8, 1.1) translateY(-10px);
    }
    50% {
        transform: scale(1) translateY(0);
    }
    100% {
        transform: translateY(0);
    }
}

/* Toast */
#toast {
    visibility: hidden;
    max-width: 500px;
    height: 90px;
    margin: auto;
    background-color: gray;
    color: #fff;
    text-align: center;
    border-radius: 10px;
    position: fixed;
    z-index: 1;
    left: 0;
    right: 0;
    bottom: 30px;
    font-size: 17px;
    white-space: nowrap;
}

#toast #desc {
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 28px;
    font-weight: bold;
    height: 90px;
    overflow: hidden;
    white-space: nowrap;
}
</style>