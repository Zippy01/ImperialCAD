let tabletVisible = false; 

function toggleTablet(show) {
    const monitor = document.querySelector('.monitor');
    monitor.style.display = show ? 'block' : 'none';
    tabletVisible = show; 

    fetch(`https://${GetParentResourceName()}/setNuiFocus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            focus: show,
            cursor: show
        })
    });
}

window.addEventListener('message', function(event) {
    if (event.data.type === "DISPLAY_TABLET") {
        toggleTablet(true);
    } else if (event.data.type === "HIDE_TABLET") {
        toggleTablet(false);
    }
});

document.addEventListener('keydown', function(e) {
    if (e.key === "Escape" && tabletVisible) {
        toggleTablet(false);
        fetch(`https://${GetParentResourceName()}/closeTablet`, {
            method: 'POST'
        });
    }
});