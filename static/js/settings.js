// settings.js

document.addEventListener('DOMContentLoaded', () => {
    const loadSettingsBtn = document.getElementById('loadSettingsBtn');
    const themeInput = document.getElementById('themeInput');
    const saveSettingsBtn = document.getElementById('saveSettingsBtn');
    const settingsMsg = document.getElementById('settingsMsg');

    loadSettingsBtn.addEventListener('click', async () => {
        settingsMsg.textContent = 'Loading settings...';
        try {
            const data = await getJSON('/api/settings');
            themeInput.value = data.theme || 'default';
            settingsMsg.textContent = 'Settings loaded.';
        } catch (err) {
            console.error(err);
            settingsMsg.textContent = 'Error loading settings.';
        }
    });

    saveSettingsBtn.addEventListener('click', async () => {
        settingsMsg.textContent = 'Saving settings...';
        const theme = themeInput.value.trim() || 'default';
        try {
            const res = await postJSON('/api/settings', { theme });
            if (res.ok) {
                const data = await res.json();
                settingsMsg.textContent = data.message || 'Settings saved.';
            } else {
                settingsMsg.textContent = 'Error saving settings.';
            }
        } catch (err) {
            console.error(err);
            settingsMsg.textContent = 'Error saving settings.';
        }
    });
});
