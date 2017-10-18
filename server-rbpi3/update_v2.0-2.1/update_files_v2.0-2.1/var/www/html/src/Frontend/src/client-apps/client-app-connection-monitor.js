import Vue from "vue";

export class ClientAppConnectionMonitor {
    constructor() {
        this.vue = undefined;
        this.fetching = false;
        this.knownStates = {};
        this.callbacks = {};
    }

    register(clientApp, callback) {
        const clientAppId = +((clientApp && clientApp.id) || clientApp);
        if (!this.callbacks[clientAppId]) {
            this.callbacks[clientAppId] = [];
        }
        this.callbacks[clientAppId].push(callback);
        if (this.knownStates[clientAppId] !== undefined) {
            callback(this.knownStates[clientAppId]);
        } else {
            Vue.nextTick(() => this.fetchStates().then(() => callback(this.knownStates[clientAppId])));
        }
    }

    unregister(clientApp, callback) {
        const clientAppId = +((clientApp && clientApp.id) || clientApp);
        if (this.callbacks[clientAppId]) {
            const newCallbacks = this.callbacks[clientAppId].filter(c => c !== callback);
            if (newCallbacks.length) {
                this.callbacks[clientAppId] = newCallbacks;
            } else {
                delete this.callbacks[clientAppId];
            }
        }
    }

    fetchStates() {
        if (this.fetching) {
            return this.fetching;
        }
        const clientAppIds = Object.keys(this.callbacks);
        if (clientAppIds.length) {
            return this.fetching = this.updateKnownStates(clientAppIds)
                .then(() => this.knownStates)
                .finally(() => this.fetching = undefined);
        }
    }

    updateKnownStates(clientAppIds) {
        return this.fetching = this.$http().get('client-apps?onlyConnected=true').then(({body}) => {
            const connectedIds = body.map(app => +app.id);
            for (let clientAppId of clientAppIds) {
                const connected = connectedIds.indexOf(+clientAppId) >= 0;
                if (this.knownStates[clientAppId] !== connected) {
                    this.knownStates[clientAppId] = connected;
                    for (let callback of (this.callbacks[+clientAppId] || [])) {
                        callback(connected);
                    }
                }
            }
        });
    }

    $http() {
        if (!this.vue) {
            setInterval(() => this.fetchStates(), 7000);
            this.vue = new Vue();
        }
        return this.vue.$http;
    }
}

const clientAppConnectionMonitor = new ClientAppConnectionMonitor();

export default clientAppConnectionMonitor;
