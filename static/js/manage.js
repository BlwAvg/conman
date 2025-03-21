// manage.js

document.addEventListener('DOMContentLoaded', () => {

    // -- Create System User --
    const createUserBtn = document.getElementById('createUserBtn');
    const newUsername = document.getElementById('newUsername');
    const createUserMsg = document.getElementById('createUserMsg');

    createUserBtn.addEventListener('click', async () => {
        const username = newUsername.value.trim();
        if (!username) {
            createUserMsg.textContent = 'Please provide a username.';
            return;
        }
        createUserMsg.textContent = 'Creating user...';
        try {
            const res = await postJSON('/api/users', { username });
            if (res.ok) {
                const data = await res.json();
                createUserMsg.textContent = data.message || 'User created.';
            } else {
                const errData = await res.json();
                createUserMsg.textContent = errData.error || 'Error creating user.';
            }
        } catch (err) {
            createUserMsg.textContent = 'Request failed.';
        }
    });

    // -- Generate SSH Key Pair --
    const generateKeyBtn = document.getElementById('generateKeyBtn');
    const keyUsername = document.getElementById('keyUsername');
    const keyType = document.getElementById('keyType');
    const keyBits = document.getElementById('keyBits');
    const keyGenMsg = document.getElementById('keyGenMsg');

    generateKeyBtn.addEventListener('click', async () => {
        const username = keyUsername.value.trim();
        const kType = keyType.value.trim();
        const kBits = keyBits.value.trim();

        if (!username) {
            keyGenMsg.textContent = 'Username is required.';
            return;
        }
        if (!kType) {
            keyGenMsg.textContent = 'Key type is required.';
            return;
        }
        if (!kBits) {
            keyGenMsg.textContent = 'Key length is required.';
            return;
        }

        keyGenMsg.textContent = 'Generating key pair...';
        try {
            const res = await postJSON('/api/keys', {
                username: username,
                key_type: kType,
                bits: kBits
            });
            if (res.ok) {
                const data = await res.json();
                keyGenMsg.textContent = data.message || 'SSH keypair generated.';
            } else {
                const errData = await res.json();
                keyGenMsg.textContent = errData.error || 'Error generating keypair.';
            }
        } catch (err) {
            keyGenMsg.textContent = 'Request failed.';
        }
    });

    // -- Add Authorized Key --
    const addAuthKeyBtn = document.getElementById('addAuthKeyBtn');
    const authKeyUsername = document.getElementById('authKeyUsername');
    const authKey = document.getElementById('authKey');
    const addAuthKeyMsg = document.getElementById('addAuthKeyMsg');

    addAuthKeyBtn.addEventListener('click', async () => {
        const username = authKeyUsername.value.trim();
        const pubKey = authKey.value.trim();
        if (!username || !pubKey) {
            addAuthKeyMsg.textContent = 'Username and Public Key are required.';
            return;
        }
        addAuthKeyMsg.textContent = 'Adding public key...';
        try {
            const res = await postJSON('/api/keys/authorized', {
                username: username,
                public_key: pubKey
            });
            if (res.ok) {
                const data = await res.json();
                addAuthKeyMsg.textContent = data.message || 'Key added.';
            } else {
                const errData = await res.json();
                addAuthKeyMsg.textContent = errData.error || 'Error adding key.';
            }
        } catch (err) {
            addAuthKeyMsg.textContent = 'Request failed.';
        }
    });
});
